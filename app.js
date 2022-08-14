require('dotenv').config();
const router = require('./routes');
const express = require('express');
const database = require('./database');
const bodyParser = require('body-parser');
const path = require('path');
const morgan = require('morgan');

const app = express();
database.connectDB();

app.locals.moment = require('moment');

app.use(morgan('dev'));
app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.static('public'));
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'pug');

app.use(router);

app.listen(process.env.PORT, () => {
    console.log('App running at http://localhost:' + process.env.PORT);
});