package org.opencds.cqf.cql.engine.execution;

import org.opencds.cqf.cql.engine.debug.DebugResult;

import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;

public class EvaluationResult {
    public Map<String, Object> expressionResults;

    public EvaluationResult() {
        this.expressionResults = new LinkedHashMap<>();
    }

    public Object forExpression(String expressionName) {
        return this.expressionResults.get(expressionName);
    }

    private DebugResult debugResult;
    public DebugResult getDebugResult() {
        return debugResult;
    }
    public void setDebugResult(DebugResult debugResult) {
        this.debugResult = debugResult;
    }
    
}