<%-- 
    Document   : stamping
    Created on : 5.4.2016, 13:53:06
    Author     : Petr
--%>

<%@page import="java.io.File"%>
<%@page import="java.io.FileOutputStream"%>
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
        
        <%
            InputStream fileContent = request.getPart("filename").getInputStream();
            byte[] data = con.getBytesFromInputStream(fileContent);
            String filename = request.getPart("filename").getSubmittedFileName();
        %>
        <hr>
        <p>Soubor <code><%= filename %></code> o velikosti <code><%= data.length %></code> bajtů se zpracovává..</p>
        <%
            boolean success = false;
            File file = null;
            String stampName = filename.replace(".", "_").concat("-stamp.tsr");
            try {
                byte[] timeStampResponse = con.stamp(filename, fileContent);

                file = File.createTempFile("stamp", ".tsr", new File(System.getProperty("java.io.tmpdir")));
                file.deleteOnExit();
                FileOutputStream fos = new FileOutputStream(file);
                fos.write(timeStampResponse);
                fos.close();
                success = true;
            } catch (Exception e) {}
            
            /*/
            var uri = 'data:text/csv;charset=UTF-8,%EF%BB%BF' + encodeURI(CSV);
            var link = document.createElement("a");
            link.href = uri;
            link.style = "visibility:hidden";
            link.download = fileName + ".csv";
            //this part will append the anchor tag and remove it after automatic click
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
            //*/
            
            if (success) {
        %>
            <p>
                Hotovo, stáhněte si razítko <a href="DownloadServ?id=<%=file%>&filename=<%=stampName%>">zde</a>.
            </p>
            <p>
                <i>(už by mělo fungovat :) )</i>
            </p>
        <%
            } else {
        %>
            <p>
                Časové razítko se nepodařilo vytvořit!
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
