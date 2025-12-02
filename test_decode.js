const PS = require('./output/Main/index.js');

// Simulate fetching customers
fetch('http://localhost:8080/api/customers')
  .then(res => res.json())
  .then(data => {
    console.log('Fetched', data.length, 'customers');
    console.log('First customer:', JSON.stringify(data[0], null, 2));
  })
  .catch(err => console.error('Error:', err));
