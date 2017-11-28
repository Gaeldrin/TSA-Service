<%-- 
    Document   : stamping
    Created on : 5.4.2016, 13:53:06
    Author     : Petr
--%>

<%@page import="java.io.InputStream"%>
<%@page import="org.bouncycastle.tsp.TimeStampResponse"%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>CESNET TSA</title>
        <jsp:useBean id="con" class="com.cesnet.pki.tsa.TSAConnector" scope="session"/>
    </head>
    <body>
        <h1>CESNET Time Stamp Authority JSP</h1>
        
        <%
            InputStream fileContentStream = request.getPart("file").getInputStream();
            byte[] fileContentByte = con.getBytesFromInputStream(fileContentStream);
            String filename = request.getPart("file").getSubmittedFileName();
        %>
        <hr>
        <p>Soubor <code><%= filename %></code> o velikosti <code><%= fileContentByte.length %></code> bajtů se zpracovává..</p>
        <%
            boolean success = false;
//            String stampName = filename.replace(".", "_").concat("-stamp.tsr");
            String stampName = filename.concat(".tsr");
            try {
                con.timeStampResponse = con.stamp(filename, fileContentByte);
                success = true;
            } catch (Exception e) {}
            
            if (success) {
        %>
            <p>
                Hotovo, stáhněte si razítko <a href="download.jsp?filename=<%=stampName%>">zde</a>.
            </p>
        <%
            } else {
        %>
            <p>
                Časové razítko se nepodařilo vytvořit. Zkuste to prosím znovu.
            </p>
        <%
            };
        %>
        <br>
        <br>
        <hr>
        <i><a href="index.html">Návrat na hlavní stránku</a></i>
    </body>
</html>
