/**
 * SOQLSelect class 1.0.0
 *
 * @description This class represents a SOQLSelect.
 *
 * @author Nadezhda Podobed
 * @date 23.02.2019
 */
public with sharing class SOQLSelect {

    private String objectName { get; private set; }

    private Set<String> requiredFields { get; private set; }

    private Set<String> innerQueries { get; private set; }

    private SOQLSelect(Builder builder) {
        this.objectName = builder.objectName;
        this.requiredFields = builder.requiredFields;
        this.innerQueries = builder.innerQueries;
    }

    public override String toString() {
        String selectToken = '';

        Set<String> queryFields = new Set<String>();


        if (requiredFields != null) {
            queryFields.addAll(requiredFields);
        }

        if (innerQueries != null) {
            queryFields.addAll(innerQueries);
        }

        if (!queryFields.isEmpty()) {
            selectToken = 'SELECT ' + String.join(new List<String>(queryFields), ', ');
        }

        return selectToken;
    }

    public class Builder {

        private String objectName;

        private Set<String> requiredFields;

        private Set<String> innerQueries;

        public Builder setObject(String objectName) {
            this.objectName = objectName;
            return this;
        }


        public Builder setRequiredFields(Set<String> requiredFields) {
            this.requiredFields = requiredFields;
            return this;
        }

        public Builder setInnerQueries(Set<String> innerQueries) {
            this.innerQueries = innerQueries;
            return this;
        }

        public SOQLSelect build() {
            return new SOQLSelect(this);
        }

    }

    public class SOQLSelectException extends Exception {}

}