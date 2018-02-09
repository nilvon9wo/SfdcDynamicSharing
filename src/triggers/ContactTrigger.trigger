trigger ContactTrigger on Contact (after insert, after update) {
	System.debug('######## ContactTrigger: ' + Trigger.new);
    new F45_TRIG_TriggerHandlerInvoker(new ContactTriggerHandler()).invoke(new F45_TRIG_TriggerWrapper());  
}