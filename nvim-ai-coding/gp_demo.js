const http = require('http');
const port = 3000;

// TODO: Refactor this function to be more efficient and use modern JavaScript features
function processUserData(users) {
    return users
        .filter(user => user.age >= 18)
        .map(user => ({
            name: user.name,
            email: user.email,
            isAdult: true
        }));
}

// TODO: Explain how this function works and suggest improvements
function logRequest(req) {
    console.log('Request received at:', new Date(), 'for URL:', req.url);
}

// TODO: make it 10 users and rename them be from random marvel movies
function getUsers(callback) {
    // Simulating database call
    setTimeout(() => {
        const users = [
            { name: 'Tony Stark', email: 'tony.stark@example.com', age: 48 },
            { name: 'Steve Rogers', email: 'steve.rogers@example.com', age: 101 },
            { name: 'Natasha Romanoff', email: 'natasha.romanoff@example.com', age: 35 },
            { name: 'Bruce Banner', email: 'bruce.banner@example.com', age: 49 },
            { name: 'Thor Odinson', email: 'thor.odinson@example.com', age: 1500 },
            { name: 'Clint Barton', email: 'clint.barton@example.com', age: 41 },
            { name: 'Wanda Maximoff', email: 'wanda.maximoff@example.com', age: 29 },
            { name: 'Peter Parker', email: 'peter.parker@example.com', age: 18 },
            { name: 'Stephen Strange', email: 'stephen.strange@example.com', age: 42 },
            { name: 'T\'Challa', email: 'tchalla@example.com', age: 35 }
        ];
        callback(null, users);
    }, 1000);
}

const server = http.createServer((req, res) => {
    logRequest(req);

    if (req.url === '/users') {
        getUsers((err, users) => {
            if (err) {
                res.writeHead(500, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ error: 'Error fetching users' }));
            } else {
                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify(processUserData(users)));
            }
        });
    } else {
        res.writeHead(404, { 'Content-Type': 'text/plain' });
        res.end('Not Found');
    }
});

server.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
});
