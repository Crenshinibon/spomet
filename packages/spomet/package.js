Package.describe({
   summary: 'Spomet is an example package to provide fulltext search' 
});

Package.on_use(function (api) {
   api.use('coffeescript',['client','server']);
   api.use('templating', 'client');
   
   api.export('Spomet');
   
   api.add_files('md5.js', ['server']);
   api.add_files('provide_session_id.coffee',['server','client']);
   
   api.add_files('indexes/threegram.coffee','server');
   api.add_files('indexes/fullwords.coffee','server');
   api.add_files('indexes/wordgroup.coffee','server');
   
   api.add_files('indexes/documents.coffee','server')
   api.add_files('indexes/index.coffee','server');
   
   api.add_files('shared.coffee',['server','client']);
   api.add_files('collections.coffee',['server','client']);
   
   api.add_files('server.coffee','server');
   
   api.add_files('search_field.html','client');
   api.add_files('client.coffee','client');
   
   });

Package.on_test(function (api) {
    api.export('ThreeGramIndex');
    api.export('FullWordIndex');
    api.export('WordGroupIndex');
});