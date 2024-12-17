const express = require('express');
const productsRoute = require('./routes/products')

// Define the app
const app = express();

// Enable JSON
app.use(express.json({ extended: true}));

// Configure the port
const port = 3000;

app.use('/api', productsRoute)

// Server
app.listen( (port), () => {
    console.log(`App is running on port ${port}`);
});