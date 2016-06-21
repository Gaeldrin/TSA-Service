<%-- 
    Document   : verification
    Created on : 5.4.2016, 13:53:06
    Author     : Petr
--%>

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
        
        <%
            /* load files */
            InputStream origFile = request.getPart("originalFile").getInputStream();
            String filename = request.getPart("originalFile").getSubmittedFileName();
            
            InputStream timestamp = request.getPart("timestamp").getInputStream();
            String timestampName = request.getPart("timestamp").getSubmittedFileName();
            
            byte[] message = null;
            TimeStampResponse tsr = null;
            String error = "";
            try {
                message = con.getBytesFromInputStream(origFile);
                tsr = con.parseTSR(timestamp);
            } catch (Exception e) {
                error = e.getClass().getName().concat(": ").concat(e.getMessage());
            }
            
            if (!error.isEmpty()) {
        %>
        <p>Razítko se nepodařilo přečíst!
            Opravdu je <%=timestampName%> časové razítko?</p>
        <p>Detaily:<br>
        <%=error%></p>
    </body>
</html>
        <%
            } else {
        %>
        <p>Časové razítko bylo úspěšně přečteno.</p>
        <hr>
        
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
        <p>Razítko neodpovídá zvolenému souboru!
            Buď byl soubor je <%=filename%> změněn nebo bylo časové razítko vytvořeno pro jiný soubor.</p>
        <p>Detaily:<br>
        <%=error%></p>
    </body>
</html>
            <%
                } else {
            %>
            <p>Razítko bylo úspěšně ověřeno - soubor nebyl změněn.</p>
            <hr>
            
                <%
                    // to be implemented
                %>
            <p>Ověření certifikátů ještě nebylo implementováno.</p>
        <%
                // end
                }
            }
        %>
    </body>
</html>
