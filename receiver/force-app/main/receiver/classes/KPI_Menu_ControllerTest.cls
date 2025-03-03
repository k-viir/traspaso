@isTest
public class KPI_Menu_ControllerTest {
    @testSetup
    static void setupTestData() {
        // Crear datos de prueba
        List<eext__Organization__c> organizations = new List<eext__Organization__c>();
        for (Integer i = 0; i < 10; i++) {
            organizations.add(new eext__Organization__c(
                Name = 'Test Org',
                eext__Last_connection__c = Date.today().addDays(-i)
            ));
        }
        insert organizations;
    }

    @isTest
    static void testGetRecordsWithoutSearchTerm() {
        // Llamar al método sin el parámetro de fecha (consulta inicial)
        String orgName = 'Test Org';
        List<sObject> results = KPI_Menu_Controller.getRecords(null, orgName);

        // Verificar que se devuelven registros y la cantidad correcta
        System.assertEquals(5, results.size(), 'Se deben devolver 5 registros.');

        // Verificar que los registros son los esperados
        for (sObject record : results) {
            eext__Organization__c org = (eext__Organization__c) record;
            System.assertEquals(orgName, org.Name, 'El nombre de la organización debe coincidir.');
        }
    }

    @isTest
    static void testGetRecordsWithSearchTerm() {
        // Llamar al método con el parámetro de fecha (consulta con fecha de búsqueda)
        Date searchTerm = Date.today();
        String orgName = 'Test Org';
        List<sObject> results = KPI_Menu_Controller.getRecords(searchTerm, orgName);

        // Verificar que se devuelven registros y la cantidad correcta
        System.assertEquals(1, results.size(), 'Se debe devolver 1 registro.');

        // Verificar que los registros son los esperados
        for (sObject record : results) {
            eext__Organization__c org = (eext__Organization__c) record;
            System.assertEquals(orgName, org.Name, 'El nombre de la organización debe coincidir.');
            System.assertEquals(searchTerm, org.eext__Last_connection__c, 'La fecha de última conexión debe coincidir con el término de búsqueda.');
        }
    }

    @isTest
    static void testGetRecordsWithNoMatches() {
        // Llamar al método con un parámetro de fecha que no coincide con ningún registro
        Date searchTerm = Date.today().addYears(-1);
        String orgName = 'Test Org';
        List<sObject> results = KPI_Menu_Controller.getRecords(searchTerm, orgName);

        // Verificar que no se devuelven registros
        System.assertEquals(0, results.size(), 'No se deben devolver registros.');
    }
}
