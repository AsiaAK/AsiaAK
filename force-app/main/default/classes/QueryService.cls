/**
 * QueryService class 1.0.0
 *
 * @description This class represents a QueryService.
 *
 * @author Nadezhda Podobed
 * @date 23.02.2019
 */
public with sharing class QueryService {

    public static String getCondition(String fieldName, String sign, String fieldValue, Boolean isString) {
        String condition = '';

        if (String.isNotBlank(fieldName) && String.isNotBlank(sign) && isString != null) {
            if (isString) {
                condition = String.format('{0} {1} \'\'{2}\'\'', new List<String>{fieldName, sign, fieldValue});
            } else {
                condition = String.format('{0} {1} ' + fieldValue, new List<String>{fieldName, sign});
            }
        }

        return condition;
    }

}