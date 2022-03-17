import 'package:gsheets/gsheets.dart';

class GoogleSheetsApi {
  // create credentials
  static const _credentials = r'''
  {
  "type": "service_account",
  "project_id": "flutter-finances",
  "private_key_id": "16031791630a9fed14e3fa9bc8aaa35eb3d573c6",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCTctDSFiIewnwF\nmWBEcAmpoOA9VUpm3m4ofeTY2Xl6RBhCvba6/aMPjuu8sIaIP2hjk1Vwl6dQXwef\n01wvvWCagjhcRGS+wcRmzHkRFBSb+zp5RAnLGxoMJiZduh793qtIcXHE6Due98VB\nUmevVhpZl2KE+3PHvR55pQEdWiinWDjFDJ0xWy5kwaB6ZJZk0IazsMd0ERKTmJuw\nFl9jcsDpPaV24/AtBVctH3r/vTv2zHFRGkEsF4yTz80BG1F0v8Zl7EHwQqXKRWaZ\nXY5S1BHTSSctZb40lVwnS8C5S46GJHret+BiYqUysTntwMj+MWyvSq+zMN+AU7vI\nvYgndL9JAgMBAAECggEAAJG/geG/LdhwzceitOx/jcBhBYgtNXvAwhS4PG6jxpXp\nVgWvGhKl45IKrznwZKGMHCSzH9z8E1Gm3s0kcB8NtLYSJOLu9RyaObMmukhxmhpQ\nJhosNDjiU0m5M0WxfKnlPQ7DXar939js3wGnoMfHuUY1c0yMQdjoQ6ZBzsT02Nsi\nv78e1jbFRdVEUskEdrGfafxn5hQNsD1QyRL7CXNJpHBVO97tKE6SvnTOAgIMDKCF\n6nDi4Oi1WzdNXqoZn2KMhtqCcCvRbarIgNEMxNk4bs5PWQuYe8w0v2yy2evg+hKv\nzjWVLUvKqOYIGpIAmCETJG0OpOqD0q2nwScrT0mcrQKBgQDJ3AOzzHSjCgvFRuUY\nPF9KdY+grrvstd4wC1bmNMdLAjhxi6JKUsPrZL2vHyTO44jLwif1hmazqfWCoIlb\n+1GaT0xD1Y15jO3sHwl/IkTcpbo5GG4HI4owKJWz51f/nWEAkxz9VLcFoNLv8vcM\nKPwWmuWSHJ0gQ6/839D14MDehQKBgQC6/tx1kSbtFSOnpH2E0SoMt7W8aCgOZvB9\nkDrNdMFsIogzmr2CrKV7nkC8vEbn84VJ2Psykzp/J1a8ukCRWRe9waZRPwxveBzP\nndS80JVtM52OS0jf+1aQ8ZHadhulPxYVFCtrVNrh5sgnm9m0kxAvOwymRcDEwQPt\nuFVqVvPC9QKBgQCD2iqw7wPg21cE7WIHiqfTwyamFny6CbGwQDfq9t6WqESmJkdD\ntPw0bgFYukcYvJdGQPRI9BlxkbrEMIiIhIiw+sseJAfdNajTaxKQ8Jl6ZuZVFRgJ\nobVJ77iZYqugU/Rgo7dz4joKexpNka69SqgfO95oqjgYMx5pVujvMnfI4QKBgH5l\nxYkmm2RIFLi9pCaB5+V+zDZVRTYu+MI3GrhEAnZghSY0o4LPxm/f0ayBq4AgCGmZ\nZHqUMEdAxQ1+7CQTT8vxOMXUU0iJrRfdfK5AY7DT4d0MIG9eCe6hi1Ba42b4VKnc\n31iGnAl0oLi9TRQVECyMwoklvx5/xXMLVZkyu0R9AoGBAKHHls7b8wkMvJjsG+ix\nuJM6fYT8PVYoQ2KW0sxZHWb3R/hRB6MbqD/upswlgPuEt/wVoMcg2DAuRO65aVYy\nM6BkpdymFw8WfYwi4OeUGSMCURM6ekcKrmrutaxJATIpl8A0q0ojmHsaHsMm4VZu\nB3c9EcmI8rLhcqhxohOy442C\n-----END PRIVATE KEY-----\n",
  "client_email": "flutter-finances@flutter-finances.iam.gserviceaccount.com",
  "client_id": "112921709517449116439",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/flutter-finances%40flutter-finances.iam.gserviceaccount.com"
}

  ''';

  // set up & connect to the spreadsheet
  static const _spreadsheetId = '1dybYeBUY-wxjNIMK5iCz6LLgWsuqgeVtk7omPfLZ6GA';
  static final _gsheets = GSheets(_credentials);
  static Worksheet? _worksheet;

  // some variables to keep track of..
  static int numberOfTransactions = 0;
  static List<List<dynamic>> currentTransactions = [];
  static bool loading = true;

  // initialise the spreadsheet!
  Future init() async {
    final ss = await _gsheets.spreadsheet(_spreadsheetId);
    _worksheet = ss.worksheetByTitle('Sheet1');
    countRows();
  }

  // count the number of notes
  static Future countRows() async {
    while ((await _worksheet!.values
            .value(column: 1, row: numberOfTransactions + 1)) !=
        '') {
      numberOfTransactions++;
    }
    // now we know how many notes to load, now let's load them!
    loadTransactions();
  }

  // load existing notes from the spreadsheet
  static Future loadTransactions() async {
    if (_worksheet == null) return;

    for (int i = 1; i < numberOfTransactions; i++) {
      final String transactionName =
          await _worksheet!.values.value(column: 1, row: i + 1);
      final String transactionAmount =
          await _worksheet!.values.value(column: 2, row: i + 1);
      final String transactionType =
          await _worksheet!.values.value(column: 3, row: i + 1);

      if (currentTransactions.length < numberOfTransactions) {
        currentTransactions.add([
          transactionName,
          transactionAmount,
          transactionType,
        ]);
      }
    }
    // this will stop the circular loading indicator
    loading = false;
    
  }


  // insert a new transaction
  static Future insert(String name, String amount, bool _isIncome) async {
    if (_worksheet == null) return;
    numberOfTransactions++;
    currentTransactions.add([
      name,
      amount,
      _isIncome == true ? 'income' : 'expense',
    ]);
    await _worksheet!.values.appendRow([
      name,
      amount,
      _isIncome == true ? 'income' : 'expense',
    ]);
  }

  static double calculateIncome() {
    double totalIncome = 0;
    for (int i = 0; i < currentTransactions.length; i++) {
      if (currentTransactions[i][2] == 'income') {
        totalIncome += double.parse(currentTransactions[i][1]);
      }
    }
    return totalIncome;
  }

  static double calculateExpense() {
    double totalExpense = 0;
    for (int i = 0; i < currentTransactions.length; i++) {
      if (currentTransactions[i][2] == 'expense') {
        totalExpense += double.parse(currentTransactions[i][1]);
      }
    }
    return totalExpense;
  }
}