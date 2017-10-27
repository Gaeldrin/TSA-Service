<%-- 
    Document   : download
    Created on : 27.10.2017, 14:15:57
    Author     : Petr
--%>
<%@ page contentType="applicaton/octet-stream" %>
<jsp:useBean id="con" class="com.cesnet.pki.tsa.TSAConnector" scope="session"/>
<%
    String filename = request.getParameter("filename");
    response.setHeader("Content-length", Integer.toString(con.timeStampResponse.length));
    response.setHeader("Content-Disposition", "attachment; filename="+filename);
    response.getOutputStream().write(con.timeStampResponse, 0, con.timeStampResponse.length);
    response.getOutputStream().flush();
%>