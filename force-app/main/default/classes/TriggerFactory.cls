/**
 * TriggerFactory class 1.0.0
 *
 * @description This class represents a TriggerFactory.
 *
 * @author Nadezhda Podobed
 * @date 19.03.2019
 */
public with sharing class TriggerFactory {

    public static final Map<String, TriggerSetting__mdt> SOBJECT_TRIGGER_SETTINGS = new Map<String, TriggerSetting__mdt>();
	public static final Map<String, TriggerHandler> SOBJECT_TRIGGER_HANDLERS = new Map<String, TriggerHandler>();

	public static void execute(Schema.SObjectType sObjectType) {
		TriggerHandler triggerHandler = getHandler(sObjectType);

		if (triggerHandler != null) {
            triggerHandler.execute(Trigger.operationType, Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
		}
	}

	public static void enable(Schema.SObjectType sObjectType) {
        if (sObjectType != null) {
			String sObjectName = sobjectType.getDescribe().getName().removeEnd('__c').remove('_');

            TriggerSetting__mdt triggerSetting = getTriggerSetting(sObjectName);

            if (triggerSetting != null) {
                triggerSetting.TriggerEnabled__c = true;

                SOBJECT_TRIGGER_SETTINGS.put(sObjectName, triggerSetting);
            }
        }
	}

	public static void disable(Schema.SObjectType sObjectType) {
        if (sObjectType != null) {
			String sObjectName = sobjectType.getDescribe().getName().removeEnd('__c').remove('_');

            TriggerSetting__mdt triggerSetting = getTriggerSetting(sObjectName);

            if (triggerSetting != null) {
                triggerSetting.TriggerEnabled__c = false;

                SOBJECT_TRIGGER_SETTINGS.put(sObjectName, triggerSetting);
            }
        }
	}

	private static TriggerHandler getHandler(Schema.SObjectType sObjectType) {
		TriggerHandler handler;

		if (sObjectType != null) {
			String sObjectName = sobjectType.getDescribe().getName().removeEnd('__c').remove('_');

            TriggerSetting__mdt triggerSetting = getTriggerSetting(sObjectName);
            System.debug(JSON.serializePretty(triggerSetting));

            if (triggerSetting != null && triggerSetting.TriggerEnabled__c) {
                if (SOBJECT_TRIGGER_HANDLERS.containsKey(sObjectName)) {
                    handler = SOBJECT_TRIGGER_HANDLERS.get(sObjectName);
                } else {
                    String handlerName = String.format(
                        '{0}TriggerHandler',
                        new List<String>{sObjectName}
                    );

                    Type handlerType = Type.forName('', handlerName);

                    if (handlerType != null) {
                        handler = (TriggerHandler) handlerType.newInstance();

                        SOBJECT_TRIGGER_HANDLERS.put(sObjectName, handler);
                    }
                }
            }
		}

		return handler;
	}

    private static TriggerSetting__mdt getTriggerSetting(String sObjectName) {
        TriggerSetting__mdt triggerSetting;

        if (String.isNotBlank(sObjectName)) {
            if (SOBJECT_TRIGGER_SETTINGS.containsKey(sObjectName)) {
                triggerSetting = SOBJECT_TRIGGER_SETTINGS.get(sObjectName);
            } else {
                List<TriggerSetting__mdt> triggerSettings = [
                        SELECT TriggerEnabled__c
                        FROM TriggerSetting__mdt
                        WHERE DeveloperName = :sObjectName
                ];
                if (!triggerSettings.isEmpty()) {
                    triggerSetting = triggerSettings.get(0);
                } else {
                    triggerSetting = new TriggerSetting__mdt(
                        TriggerEnabled__c = false
                    );
                }

                SOBJECT_TRIGGER_SETTINGS.put(sObjectName, triggerSetting);
            }
        }

        return triggerSetting;
    }

}