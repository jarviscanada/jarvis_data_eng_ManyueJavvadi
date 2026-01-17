# Introduction

This project implements a simplified version of the Unix `grep` command in Java. The application recursively searches files under a given root directory, matches lines using a regular expression, and writes the matched results to an output file. The project is built using Core Java, Maven for dependency and build management, SLF4J for logging, Java 8 Lambdas and Streams for functional-style processing, and Docker for packaging and distribution. The goal of this project is to demonstrate clean design, modular implementation, and production-ready deployment practices.

# Quick Start

## Prerequisites

* Java 8+
* Maven
* Docker (optional, for containerized execution)

## Run with Maven (local)
```bash
cd core_java/grep
mvn clean package
java -jar target/grep-1.0-SNAPSHOT-shaded.jar "error" ./data/txt ./out/result.txt
```

## Run with Docker
```bash
docker run --rm \
  -v $(pwd)/data:/data \
  -v $(pwd)/out:/out \
  manyuej/grep "error" /data /out/result.txt
```

# Implementation

## Pseudocode
```
matchedLines = []

files = listFilesRecursively(rootPath)

for each file in files:
    lines = readLines(file)
    for each line in lines:
        if containsPattern(line):
            matchedLines.add(line)

writeToFile(matchedLines)
```

The `process` method acts as a high-level workflow controller and delegates detailed logic to helper methods.

## Performance Issue

The current implementation loads all matched lines into memory before writing them to the output file. This can cause memory issues when processing very large files or directories. To improve performance, the design can be optimized by using Java Streams with lazy evaluation, streaming file lines directly to the output writer instead of storing them in memory.

# Test

The application was tested manually using sample text files (e.g., `shakespeare.txt`). Test cases included:

* Valid regex with expected matches
* Regex with no matches
* Invalid root directory
* Nested directory structures

Results were verified by comparing output files with expected `grep` command output.

# Deployment

The application was dockerized using a lightweight Java runtime image. A shaded (fat) JAR was created using Maven Shade Plugin to bundle all runtime dependencies, including SLF4J. The Docker image runs the application using `java -jar`, allowing users to execute the grep app without installing Java or Maven locally.

# Improvement

1. Refactor file processing to fully use Java Streams for better memory efficiency.
2. Add unit tests using JUnit instead of relying only on manual testing.
3. Enhance logging configuration (e.g., external log4j configuration, log levels).