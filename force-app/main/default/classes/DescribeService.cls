/**
 * DescribeService class 1.0.0
 *
 * @description This class represents a DescribeService.
 *
 * @author Nadezhda Podobed
 * @date 23.02.2019
 */
public with sharing class DescribeService {

    public static Schema.DescribeSObjectResult getDescribeSObjectResult(String objectName) {
        Schema.DescribeSObjectResult sObjectResult;

        if (String.isNotBlank(objectName)) {
            Type objectType = Type.forName(objectName);

            if (objectType != null) {
                sObjectResult = ((SObject) objectType.newInstance())
                        .getSObjectType()
                        .getDescribe();
            }
        }

        return sObjectResult;
    }

}