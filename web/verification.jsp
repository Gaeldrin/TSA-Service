<%-- 
    Document   : verification
    Created on : 5.4.2016, 13:53:06
    Author     : Petr
--%>

<%@page import="com.cesnet.pki.tsa.TSAConnector.Pair"%>
<%@page import="com.cesnet.pki.tsa.TSAConnector"%>
<%@page import="java.util.Collection"%>
<%@page import="java.util.stream.Collectors"%>
<%@page import="java.util.List"%>
<%@page import="org.bouncycastle.tsp.TimeStampRequest"%>
<%@page import="org.bouncycastle.tsp.TimeStampResponse"%>
<%@page import="java.io.InputStream"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>CESNET TSA</title>
        <jsp:useBean id="con" class="com.cesnet.pki.tsa.TSAConnector"/>
    </head>
    <body>
        <h1>CESNET Time Stamp Authority JSP</h1>
        <hr>
        
        <ol>
            
        <%  
            /* load files */
            byte[] message = null;
            TimeStampResponse tsr = null;
            String error = "";
            
            InputStream origFile = request.getPart("file[0]").getInputStream();
            String filename = request.getPart("file[0]").getSubmittedFileName();
            
            InputStream timestamp = request.getPart("file[1]").getInputStream();
            String timestampName = request.getPart("file[1]").getSubmittedFileName();
            
            if (timestampName.isEmpty() || filename.isEmpty()) {
        %>
        <li><h3>Razítko nebo soubor se nepodařilo přečíst!</h3>
            Opravdu jste nahráli oba požadované soubory?</li>
        </ol>
        <br>
        <br>        > obsolete part <
        <hr>
        <i><a href="index.html">Návrat na hlavní stránku</a></i>
    </body>
</html>
        
        <%
                return;
            }
                
            byte[] data1 = con.getBytesFromInputStream(origFile);
            byte[] data2 = con.getBytesFromInputStream(timestamp);

            byte[][] files = new byte[2][];
            files[0] = data1;
            files[1] = data2;

            Pair p = con.findTS(files);
            tsr = p.tsr;
            message = p.msg;

            if (message == data2) {
                String temp = filename;
                filename = timestampName;
                timestampName = temp;
            }
            
            if (tsr == null) {
        %>
        <li><h3>Razítko se nepodařilo přečíst!</h3>
        <p>Detaily:<br>
        <%=error%></p>
        
        <%
            } else {
        %>
        <li><h3>Časové razítko bylo úspěšně přečteno.</h3>
            Soubor <code><%=timestampName%></code> byl rozpoznán jako platné razítko.</li>
        
            <%
                TimeStampRequest tsq = con.createCorrespondingTSQ(message, tsr);

                // compare hashes
                try {
                    tsr.validate(tsq);
                } catch (Exception e) {
                    error = e.getClass().getName().concat(": ").concat(e.getMessage());
                }

                if (!error.isEmpty()) {
            %>
        <li><h3>Razítko neodpovídá zvolenému souboru!</h3>
            Buď byl soubor <code><%=filename%></code> změněn nebo bylo časové razítko vytvořeno pro jiný soubor.</li>
        <p>Detaily:<br>
        <%=error%></p>
        
            <%
                } else {
            %>
            <li><h3>Razítko bylo úspěšně ověřeno.</h3>
                <p>Razítko náleží souboru <code><%=filename%></code>.</p>
            
                <b>Detaily razítka:</b>
                <code><table>
                    <tr>
                        <td>Time:</td>
                        <td><%=tsr.getTimeStampToken().getTimeStampInfo().getGenTime()%></td>
                    </tr>
                    <tr>
                        <td>TSA:</td>
                        <td><%=tsr.getTimeStampToken().getTimeStampInfo().getTsa()%></td>
                    </tr>
                    <tr>
                        <td>Serial number:</td>
                        <td><%=tsr.getTimeStampToken().getTimeStampInfo().getSerialNumber()%></td>
                    </tr>
                    <tr>
                        <td>Policy:</td>
                        <td><%=tsr.getTimeStampToken().getTimeStampInfo().getPolicy()%>
                            [<%=con.getDigestAlg(tsr.getTimeStampToken().getTimeStampInfo().getMessageImprintAlgOID()).getAlgorithmName()%>]</td>
                    </tr>
                </table></code>
                </p>
            </li>
            
                <%
                    if (con.containsCertificate(tsr)) {
                        try {
                            con.verifyCertificateIncluded(tsr.getTimeStampToken());
                        } catch (Exception e) {
                            error = e.getClass().getName().concat(": ").concat(e.getMessage());
                        }

                        if (!error.isEmpty()) {
                %>
                    <li><h3>Razítko není důvěryhodné!</h3>
                        Razítko obsahuje certifikát, který není v pořádku.</li>
                    <p>Detaily:<br>
                    <%=error%></p>
                        <%
                        } else {    
                        %>
                    <li><h3>Razítko je důvěryhodné.</h3>
                        Razítko obsahuje důvěryhodný certifikát, který byl použit při podepsání razítka.
                        <%
                        }
                    } else {
                        InputStream certIS = null;
                        String certName = null;
                        try {
                            certIS = request.getPart("file[2]").getInputStream();
                            certName = request.getPart("file[2]").getSubmittedFileName();
                        } catch (Exception e) {}
                        
                        if (certIS == null || certName.isEmpty()) {
                    %>
                    <li><h3>Nelze ověřit pravost razítka.</h3>
                         <p>Výše uvedené časové razítko neobsahuje certifikát, jímž bylo podepsáno.</li>
                    

                    <%
                        } else {
                            try {
                                con.verifyCertificateFile(tsr, certIS);
                            } catch (Exception e) {
                                error = e.getClass().getName().concat(": ").concat(e.getMessage());
                            }

                            if (!error.isEmpty()) {
                    %>
                    <li><h3>Vámi nahraný certifikát neodpovídá certifikátu razítka!</h3>
                         K podepsání razítka byl použit jiný certifikát, než který jste nahráli, nebo certifikát není důvěryhodný.
                         <br>
                         Zkontrolujte prosím správnost certifikátu.</li>
                    <p>Detaily:<br>
                    <%=error%></p>

            <%
                            } else {
                            %>
                            <li><h3>Razítko je důvěryhodné.</h3>
                                K vytvoření razítka byl použit Vámi nahraný certifikát <code><%=certName%></code>.</li>

                            <%
                        // end
                            }
                        }
                    }
                }
            }
        
        %>
            
        </ol>
        <br>
        <br>
        <hr>
        <i><a href="index.html">Návrat na hlavní stránku</a></i>
    </body>
</html>
