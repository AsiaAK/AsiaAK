/**
 * SOQLQuery class 1.0.0
 *
 * @description This class represents a SOQLQuery.
 *
 * @author Nadezhda Podobed
 * @date 23.02.2019
 */
public with sharing class SOQLQuery {

    private SOQLSelect selectToken { get; private set; }

    private String objectName { get; private set; }

    private String whereConditions { get; private set; }

    private SOQLOrderBy orderByToken { get; private set; }

    private String queryLimit { get; private set; }

    private SOQLQuery(Builder builder) {
        this.selectToken = builder.selectToken;
        this.objectName = builder.objectName;
        this.whereConditions = builder.whereConditions;
        this.orderByToken = builder.orderByToken;
        this.queryLimit = builder.queryLimit;
    }

    public override String toString() {
        String soqlQuery = '';

        if (selectToken != null && String.isNotBlank(selectToken.toString()) && String.isNotBlank(objectName)) {
            List<String> soqlTokens = new List<String>();

            soqlTokens.add(selectToken.toString());

            soqlTokens.add('FROM ' + objectName);

            if (String.isNotBlank(whereConditions)) {
                soqlTokens.add('WHERE ' + whereConditions);
            }


            if (orderByToken != null) {
                soqlTokens.add(orderByToken.toString());
            }

            if (String.isNotBlank(queryLimit)) {
                soqlTokens.add('LIMIT ' + queryLimit);
            }

            soqlQuery = String.join(soqlTokens, ' ');
        }

        return soqlQuery;
    }

    public class Builder {

        private SOQLSelect selectToken;

        private String objectName;

        private String whereConditions;


        private SOQLOrderBy orderByToken;

        private String queryLimit;

        public Builder setSelectToken(SOQLSelect selectToken) {
            this.selectToken = selectToken;
            return this;
        }

        public Builder setObject(String objectName) {
            this.objectName = objectName;
            return this;
        }

        public Builder setWhereConditions(String whereConditions) {
            this.whereConditions = whereConditions;
            return this;
        }


        public Builder setOrderByToken(SOQLOrderBy orderByToken) {
            this.orderByToken = orderByToken;
            return this;
        }

        public Builder setQueryLimit(String queryLimit) {
            this.queryLimit = queryLimit;
            return this;
        }

        public SOQLQuery build() {
            return new SOQLQuery(this);
        }

    }

}