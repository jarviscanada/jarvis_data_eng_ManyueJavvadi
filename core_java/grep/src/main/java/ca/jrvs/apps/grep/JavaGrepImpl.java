package ca.jrvs.apps.grep;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.*;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

public class JavaGrepImpl implements JavaGrep {

    private static final Logger logger =
            LoggerFactory.getLogger(JavaGrepImpl.class);

    private String rootPath;
    private String regex;
    private String outFile;

    /**
     * Entry point
     * args[0] regex
     * args[1] root directory
     * args[2] output file
     */
    public static void main(String[] args) {
        if (args.length != 3) {
            logger.error("Usage: regex rootPath outFile");
            System.exit(1);
        }

        JavaGrepImpl app = new JavaGrepImpl();
        app.setRegex(args[0]);
        app.setRootPath(args[1]);
        app.setOutFile(args[2]);

        try {
            app.process();
        } catch (IOException e) {
            logger.error("Error running JavaGrep", e);
        }
    }

    /**
     * High-level workflow
     */
    @Override
    public void process() throws IOException {
        List<File> files = listFiles(getRootPath());
        List<String> matchedLines = new ArrayList<>();

        for (File file : files) {
            for (String line : readLines(file)) {
                if (containsPattern(line)) {
                    matchedLines.add(line);
                }
            }
        }
        writeToFile(matchedLines);
    }

    /**
     * Recursively list files under rootDir
     */
    @Override
    public List<File> listFiles(String rootDir) {
        List<File> files = new ArrayList<>();
        File root = new File(rootDir);

        if (!root.exists()) {
            throw new IllegalArgumentException("Invalid root directory");
        }

        File[] list = root.listFiles();
        if (list == null) return files;

        for (File file : list) {
            if (file.isDirectory()) {
                files.addAll(listFiles(file.getAbsolutePath()));
            } else {
                files.add(file);
            }
        }
        return files;
    }

    /**
     * Read all lines from a file
     */
    @Override
    public List<String> readLines(File inputFile) {
        if (!inputFile.isFile()) {
            throw new IllegalArgumentException("Not a file");
        }

        List<String> lines = new ArrayList<>();
        try (BufferedReader br =
                     new BufferedReader(new FileReader(inputFile))) {

            String line;
            while ((line = br.readLine()) != null) {
                lines.add(line);
            }
        } catch (IOException e) {
            logger.error("Failed to read file {}", inputFile.getAbsolutePath(), e);
        }
        return lines;
    }

    /**
     * Check regex match
     */
    @Override
    public boolean containsPattern(String line) {
        return Pattern.compile(regex).matcher(line).find();
    }

    /**
     * Write matched lines to output file
     */
    @Override
    public void writeToFile(List<String> lines) throws IOException {
        try (BufferedWriter bw =
                     new BufferedWriter(new FileWriter(outFile))) {

            for (String line : lines) {
                bw.write(line);
                bw.newLine();
            }
        }
    }

    // Getters & Setters

    @Override
    public String getRootPath() {
        return rootPath;
    }

    @Override
    public void setRootPath(String rootPath) {
        this.rootPath = rootPath;
    }

    @Override
    public String getRegex() {
        return regex;
    }

    @Override
    public void setRegex(String regex) {
        this.regex = regex;
    }

    @Override
    public String getOutFile() {
        return outFile;
    }

    @Override
    public void setOutFile(String outFile) {
        this.outFile = outFile;
    }
}
