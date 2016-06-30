<%-- 
    Document   : verification
    Created on : 5.4.2016, 13:53:06
    Author     : Petr
--%>

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
//        List<Part> fileParts = request.getParts().stream().filter(part -> "files".equals(part.getName())).collect(Collectors.toList()); // Retrieves <input type="file" name="files" multiple />
          /* file multipart start */
//        Collection<Part> fileParts = request.getParts();
//        if (fileParts.size() < 2 || fileParts.size() > 3) {
            %>
            <!--<p>Prosím nahrajte tři soubory - Váš soubor, razítko a certifikát.</p>-->
            <%
//        } else {
//            String filename = null, timestampName = null;
//            byte[] message = null;
//            TimeStampResponse tsr = null;
//            String error = "";
//
//            int i = 0;
//            boolean tsrFound = false;
//            for (Part filePart : fileParts) {
//                if (i == 2) {
//                    break;
//                }
//                if (!filePart.getName().equals("files")) {
//                    continue;
//                }
//
//                InputStream is = filePart.getInputStream();


//Trying file <%=filePart.getSubmittedFileName()%>

<%
//                if (tsrFound) {
//                    message = con.getBytesFromInputStream(is);
//                    filename = filePart.getSubmittedFileName();
//                } else {
//                    byte[] data = con.getBytesFromInputStream(is);
//                    try {
//                        tsr = con.parseTSR(data);
//                    } catch (Exception e) {
//                        error = e.getClass().getName().concat(": ").concat(e.getMessage());
//                    }
//
//                    if (error.isEmpty()) {
//                        tsrFound = true;
//                        timestampName = filePart.getSubmittedFileName();
//                    } else {
//                        message = data;
//                        filename = filePart.getSubmittedFileName();
//                    }
//                }
//                i++;
//            }
            
//            String filename = null, timestampName = null;
            byte[] message = null;
            TimeStampResponse tsr = null;
            String error = "";
            boolean tsrFound = false;
            
            InputStream origFile = request.getPart("originalFile").getInputStream();
            String filename = request.getPart("originalFile").getSubmittedFileName();
            
            InputStream timestamp = request.getPart("timestamp").getInputStream();
            String timestampName = request.getPart("timestamp").getSubmittedFileName();
            
            InputStream certIS = request.getPart("cert").getInputStream();
            String certName = request.getPart("cert").getSubmittedFileName();
            
            if (timestampName.isEmpty() || filename.isEmpty()) {
        %>
        <li><h3>Razítko nebo soubor se nepodařilo přečíst!</h3>
            Opravdu jste nahráli oba požadované soubory?</li>
        </ol>
        <br>
        <br>
        <hr>
        <i><a href="index.html">Návrat na hlavní stránku</a></i>
    </body>
</html>
        
        <%
                return;
            }
                
            
            try {
                message = con.getBytesFromInputStream(origFile);
                tsr = con.parseTSR(con.getBytesFromInputStream(timestamp));
                tsrFound = true;
            } catch (Exception e) {
                error = e.getClass().getName().concat(": ").concat(e.getMessage());
            }
            
            if (!error.isEmpty()) {
        %>
        <li><h3>Razítko se nepodařilo přečíst!</h3>
            Opravdu je <code><%=timestampName%></code> časové razítko?</li>
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
                Razítko náleží souboru <code><%=filename%></code> a soubor nebyl změněn od <code><%=tsr.getTimeStampToken().getTimeStampInfo().getGenTime()%></code>.</li>
            
                <%
                    if (certName.isEmpty()) {
                    %>
                    <li><h3>Neposkytli jste soubor certifikátu.</h3>
                         Nenahráli jste certifikát příslušné certifikační autority k ověření pravosti razítka.</li>

                    <%
                    } else {
                        try {
                            con.verifyCertificate(tsr, certIS);
                        } catch (Exception e) {
                            error = e.getClass().getName().concat(": ").concat(e.getMessage());
                        }

                        if (!error.isEmpty()) {
                    %>
                    <li><h3>Vámi nahraný certifikát neodpovídá certifikátu razítka!</h3>
                         K podepsání razítka byl použit jiný certifikát, než který jste nahráli. Zkontrolujte prosím správnost certifikátu.</li>
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
        
        %>
            
        </ol>
        <br>
        <br>
        <hr>
        <i><a href="index.html">Návrat na hlavní stránku</a></i>
    </body>
</html>
