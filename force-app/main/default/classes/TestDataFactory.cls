@isTest
public class TestDataFactory {

    private static Id householdRecordTypeId = 
        Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HH_Account').getRecordTypeId();


    /*************************
     * Accounts
     *************************/

    private static final String ACCOUNT_BASE_NAME = 'Wright Household';

    /**
     * Create accounts with a household record type
     * No DML - returns unsaved list of sObjects
     * @param Integer Number of records to create
     */

    public static List<Account> createHouseholdAccounts(
        Integer numberOfAccounts
    ) {
        List<Account> lstAccounts = new List<Account>();
        for (Integer i = 0; i < numberOfAccounts; i++) {
            lstAccounts.add( 
                new Account(
                    Name = ACCOUNT_BASE_NAME + String.valueOf(i), 
                    RecordTypeId = householdRecordTypeId
                )
            );
        }
        return lstAccounts;
    }


    /*************************
     * Contacts
     *************************/

    private static final String CONTACT_BASE_FIRST_NAME = 'David';
    private static final String CONTACT_BASE_LAST_NAME = 'Wright';
    private static final Date CONTACT_BASE_BIRTHDATE = Date.today().addYears(-21);

    /**
     * Create contact sObjects without accounts
     * No DML - returns unsaved list of sObjects
     * @param Integer Number of contacts to create for each account
     */

    public static List<Contact> createContacts(
        Integer numberOfContacts
    ) {
        return generateContactsWithDefaults(numberOfContacts);
    }

    /**
     * Create contact sObjects for a preexisting list of accounts
     * No DML - returns unsaved list of sObjects
     * @param List<Account> Parent accounts for created contacts
     * @param Integer Number of contacts to create for each account
     */

    public static List<Contact> createContacts(
        List<Account> lstParentAccounts, Integer numberOfContacts
    ) {
        List<Contact> lstContacts = new List<Contact>();
        for (Account acc : lstParentAccounts) {
            List<Contact> lstAccountContacts = generateContactsWithDefaults(numberOfContacts);
            for (Contact ct : lstAccountContacts) {
                ct.AccountId = acc.Id;
            }
            lstContacts.addAll(lstAccountContacts);
        }
        return lstContacts;
    }

    /**
     * Create a list of default contacts with FirstName, LastName, Email, and Birthdate
     *     to be used by overloaded createContacts method
     * @param numberOfContacts Number of contacts to create
     */

    private static List<Contact> generateContactsWithDefaults(
        Integer numberOfContacts
    ) {
        List<Contact> lstDefaultCts = new List<Contact>();
        for (Integer i = 0; i < numberOfContacts; i++) {
            lstDefaultCts.add(
                new Contact(
                    FirstName = CONTACT_BASE_FIRST_NAME + String.valueOf(i),
                    LastName  = CONTACT_BASE_LAST_NAME + String.valueOf(i),
                    Email     = CONTACT_BASE_FIRST_NAME + CONTACT_BASE_LAST_NAME + String.valueOf(i) + '@testingstuff.com',
                    Birthdate = CONTACT_BASE_BIRTHDATE.addYears(-i).addMonths(i)
                )
            );
        }
        return lstDefaultCts;
    }


    /*************************
     * Membership Categories (TREX1)
     *************************/

    private static final String MEMBERSHIP_CATEGORY_BASE_NAME = 'Test Membership Category';

    /**
     * Create membership category sObjects
     * No DML - returns unsaved list of sObjects
     * @param Integer Number of membership categories to create
     */

    public static List<TREX1__Membership_Category__c> createMembershipCategories(
        Integer numberOfMembershipCategories
    ) {
        List<TREX1__Membership_Category__c> lstMembershipCategories = new List<TREX1__Membership_Category__c>();
        for (Integer i = 0; i < numberOfMembershipCategories; i++) {
            lstMembershipCategories.add(
                new TREX1__Membership_Category__c(
                    Name = MEMBERSHIP_CATEGORY_BASE_NAME + String.valueOf(i),
                    TREX1__Available_For_Purchase__c = true
                )
            );
        }
        return lstMembershipCategories;
    }

    
    /*************************
     * Programs (TREX1)
     *************************/

    private static final String PROGRAM_BASE_NAME = 'Test Program';

    /**
     * Create program sObjects
     * No DML - returns unsaved list of sObjects
     * @param Integer Number of programs to create
     */

    public static List<TREX1__Program__c> createPrograms(
        Integer numberOfPrograms
    ) {
        List<TREX1__Program__c> lstPrograms = new List<TREX1__Program__c>();
        for (Integer i = 0; i < numberOfPrograms; i++) {
            lstPrograms.add(
                new TREX1__Program__c(
                    Name = PROGRAM_BASE_NAME + String.valueOf(i),
                    TREX1__Available__c = true,
                    TREX1__Available_Online__c = true
                )
            );
        }
        return lstPrograms;
    }


    /*************************
     * Rules (TREX1)
     *************************/

    private static final String RULE_BASE_NAME = 'Test Rule';

    /**
     * Create rules sObjects
     * No DML - returns unsaved list of sObjects
     * @param Integer Number of rules to create
     */

    public static List<TREX1__Rule__c> createRules(
        Integer numberOfRules
    ) {
        List<TREX1__Rule__c> lstRules = new List<TREX1__Rule__c>();
        for (Integer i = 0; i < numberOfRules; i++) {
            lstRules.add( 
                new TREX1__Rule__c(Name = RULE_BASE_NAME + String.valueOf(i)) 
            );
        }
        return lstRules;
    }


    /*************************
     * Scheduled Rules
     *************************/

    private static final String SCHEDULED_RULE_BASE_NAME = 'Test Scheduled Rule';
    private static final String SCHEDULED_RULE_DESCRIPTION = 'A scheduled rule for testing';

    /**
     * Create scheduled rules sObjects for a list of rules
     * No DML - returns unsaved list of Scheduled Rule sObjects
     * @param List<TREX1__Rule__c> List of Rules to create scheduled rules for
     * @param Integer Number of scheduled rules to create for each rule
     */

    public static List<Scheduled_Rule__c> createScheduledRules(
        List<TREX1__Rule__c> lstParentRules, Integer numberOfScheduledRules
    ) {
        List<Scheduled_Rule__c> lstScheduledRules = new List<Scheduled_Rule__c>();
        for (TREX1__Rule__c rule : lstParentRules) {
            for (Integer i = 0; i < numberOfScheduledRules; i++) {
                lstScheduledRules.add(
                    new Scheduled_Rule__c(
                        Name = SCHEDULED_RULE_BASE_NAME + String.valueOf(i),
                        Rule__c = rule.Id,
                        Start_Date_Time__c = Datetime.now().addDays(i+1),
                        End_Date_Time__c = Datetime.now().addDays(i+2),
                        Description__c = SCHEDULED_RULE_DESCRIPTION
                    )
                );
            }
        }
        return lstScheduledRules;
    }


    /*************************
     * Users
     *************************/

    /**
     * Create external users for a list of contacts
     * No DML - returns unsaved list of sObjects
     * @param List<Contact> Parent contacts for created users
     */

    public static List<User> createExternalUsers(
        List<Contact> lstParentContacts
    ) {
        List<User> lstUsers = new List<User>();
        for (Contact ct : lstParentContacts) {
            User u = ExternalUserUtilities.getUserWithDefaults();
            u.ContactId           = ct.Id;
            u.Username            = ct.Email;
            u.Email               = ct.Email;
            u.FirstName           = ct.FirstName;
            u.LastName            = ct.LastName;
            u.Alias               = ExternalUserUtilities.getAliasFromName(ct.FirstName, ct.LastName);
            u.CommunityNickname   = ExternalUserUtilities.getNicknameFromUsername(ct.Email);
            lstUsers.add(u);
        }
        return lstUsers;
    }

}
