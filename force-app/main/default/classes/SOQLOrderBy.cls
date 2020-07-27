/**
 * SOQLOrderBy class 1.0.0
 *
 * @description This class represents a SOQLOrderBy.
 *
 * @author Nadezhda Podobed
 * @date 23.02.2019
 */
public with sharing class SOQLOrderBy {

    private String orderFields { get; private set; }

    private String orderType { get; private set; }

    private SOQLOrderBy(Builder builder) {
        this.orderFields = builder.orderFields;
        this.orderType = builder.orderType;
    }

    public override String toString() {
        String orderByToken = '';

        Set<String> queryOrderBy = new Set<String>();

        if (String.isNotBlank(orderFields)) {
            queryOrderBy.add(orderFields);
        }

        if (String.isNotBlank(orderType)) {
            queryOrderBy.add(orderType);
        }

        if (!queryOrderBy.isEmpty()) {
            orderByToken = 'ORDER BY ' + String.join(new List<String>(queryOrderBy), ' ');
        }

        return orderByToken;
    }

    public class Builder {

        private String orderFields;

        private String orderType;

        public Builder setOrderFields(String orderFields) {
            this.orderFields = orderFields;
            return this;
        }

        public Builder setOrderType(String orderType) {
            this.orderType = orderType;
            return this;
        }

        public SOQLOrderBy build() {
            return new SOQLOrderBy(this);
        }

    }

}