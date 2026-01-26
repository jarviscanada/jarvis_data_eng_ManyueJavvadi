package ca.jrvs.apps.grep;

import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

public class JavaGrepLambdaImpl extends JavaGrepImpl {

    @Override
    public void process() throws IOException {

        List<String> matchedLines =
                listFiles(getRootPath()).stream()
                        .flatMap(file -> readLines(file).stream())
                        .filter(this::containsPattern)
                        .collect(Collectors.toList());

        writeToFile(matchedLines);
    }
}
