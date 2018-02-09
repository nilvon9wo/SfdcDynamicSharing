public class GroupSelector {
    public Group selectByType(String typeName) {
    	return [
    		SELECT Id
    		FROM Group
    		WHERE Type = :typeName
    	];
    }
}