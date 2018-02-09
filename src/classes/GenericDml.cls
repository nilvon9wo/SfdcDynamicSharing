public virtual class GenericDml {
    public virtual List<Database.SaveResult> doInsert(List<SObject> sObjectList) {
    	return Database.insert(sObjectList); 
    }

    public virtual List<Database.DeleteResult> doDelete(List<SObject> sObjectList) {
    	return Database.delete(sObjectList); 
    }
}