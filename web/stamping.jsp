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
        <p>Soubor <%= filename %> o velikosti <%= data.length %> bajtů se zpracovává..</p>
        <%
            boolean success = false;
            File file = null;
            try {
                byte[] timeStampResponse = con.stamp(filename, fileContent);

                file = File.createTempFile("stamp", ".tsr", new File(System.getProperty("java.io.tmpdir")));
                file.deleteOnExit();
                FileOutputStream fos = new FileOutputStream(file);
                fos.write(timeStampResponse);
                fos.close();
                success = true;
            } catch (Exception e) {}
            
            /*
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
                Hotovo, stáhněte si razítko <a download="stamp.tsr" href="file:///<%=file%>" target="_blank">zde</a>.
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
    </body>
</html>
