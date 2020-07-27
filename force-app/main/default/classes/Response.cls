/**
 * Response class 1.0.0
 *
 * @description This class represents a Response.
 *
 * @author Nadezhda Podobed
 * @date 23.02.2019
 */
public with sharing class Response {

    public Object data { get; private set; }

    public String message { get; private set; }

    public String status { get; private set; }

    private Response(Builder builder) {
        this.data = builder.data;
        this.message = builder.message;
        this.status = builder.status;
    }

    public class Builder {

        private Object data;

        private String message;

        private String status;

        public Builder setData(Object data) {
            this.data = data;
            return this;
        }

        public Builder setMessage(String message) {
            this.message = message;
            return this;
        }

        public Builder setStatus(String status) {
            this.status = status;
            return this;
        }

        public Response build() {
            return new Response(this);
        }

    }

}