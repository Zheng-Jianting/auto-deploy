package com.processmining.logdeploy.autodeploy.util;

import com.jcraft.jsch.*;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;

public class JSchUtils {

    private static final int CONNECT_TIMEOUT = 5000;

    public static List<String> remoteExecute(Session session, String command) throws JSchException {
        List<String> resultLines = new ArrayList<>();
        ChannelExec channel = null;
        try{
            channel = (ChannelExec) session.openChannel("exec");
            channel.setCommand(command);
            try (InputStream input = channel.getInputStream()) {
                channel.connect(CONNECT_TIMEOUT);
                BufferedReader inputReader = new BufferedReader(new InputStreamReader(input));
                String inputLine = null;
                while ((inputLine = inputReader.readLine()) != null) {
                    resultLines.add(inputLine);
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            if (channel != null) {
                channel.disconnect();
            }
        }
        return resultLines;
    }

    public static void upload(Session session, String source, String destination) throws JSchException, SftpException {
        ChannelSftp channel = (ChannelSftp) session.openChannel("sftp");
        channel.connect();
        channel.put(source, destination, ChannelSftp.OVERWRITE);
        channel.disconnect();
    }

    public static void download(Session session, String source, String destination) throws JSchException, SftpException {
        ChannelSftp channel = (ChannelSftp) session.openChannel("sftp");
        channel.connect();
        channel.get(source, destination);
        channel.disconnect();
    }

}
