const express = require('express')
const bodyParser = require('body-parser');
const cors = require('cors');
const nodemailer = require('nodemailer')

const app = express()
const port = 3000

let rData = {};

let rEmail = '';
let rCode = '';

function  generateCode() {
    return Math.floor(100000 + Math.random() * 900000).toString(); // 6-digit code
  }

  let gCode = ''

  const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: 'gqasrawig@gmail.com',
      pass: 'pmcg ngng bwbe bbiq', // use app password if 2FA is on
    },
  });

const courses=[
    {id:1,title:'Nodal Linear Circuits 1 - 14 - Nodal Analysis, Part 1',author:'Mark Budnik',image:'https://static.vecteezy.com/system/resources/previews/004/937/500/non_2x/abstract-circuit-board-background-vector.jpg'},
    {id:2,title:'Linear Circuits 1 - 15 - Nodal Analysis, Part 2',author:'Mark Budnik',image:'https://static.vecteezy.com/system/resources/previews/026/183/030/non_2x/abstract-modern-technology-with-electronic-circuit-board-texture-background-big-data-visualization-futuristic-computer-technology-concept-design-illustration-vector.jpg'},
    {id:3,title:'Circuits and Electronics 1: Basic Circuit Analysis',author:'Massachusetts Institute of Technology',image:'https://static.vecteezy.com/system/resources/previews/004/937/500/non_2x/abstract-circuit-board-background-vector.jpg'}
]

const users=[
    {email:'circuitacademyproject@gmail.com',password:'123456789'},
    {email:'teab2978@gmail.com',password:'0000'},
    {email:'notofficial906@gmail.com',password:'987654321'},
]


app.use(cors()); // Enable CORS for cross-origin requests
app.use(bodyParser.json()); // Parse JSON data

app.post('/user/forgot',(req,res) => {
    rData = req.body;
    if(rData.email){
        const user = users.find(u => u.email == rData.email);
        if(user){
            rEmail = rData.email;
            gCode = generateCode();
            const mailOptions = {
                from: 'gqasrawig@gmail.com',
                to: rEmail,
                subject: 'CircuitAcademy account password recovery',
                text: `Hi there!\n\nYour verification code is: ${gCode}\nIf you didn't ask for the code just ignore or delete this email.\nThanks for using our app!`,
            };
            transporter.sendMail(mailOptions,(error,info) => {
                if(error){
                    console.log('Error sending email: ',error);
                }else{
                console.log('Email sent successfully.');
                }
            });
        }else{
            return res.status(404).json({ message: 'User not found' });
        }
    }
    else if(rData.code){
        rCode = rData.code;
        if(rCode == gCode){
            console.log('Code is valid');
            return res.status(200).json({ message: 'Code verified successfully' });

        }
        else{
            console.log('Invalid code');
            return res.status(401).json({ message: 'Invalid verification code' });
        }
    }else if(rData.newPass){
        const user = users.find(u => u.email == rEmail);
        if(user){
            user.password = rData.newPass;
            console.log(`Password updated successfully for user with email: ${rEmail}`);
            console.log(users);
            return res.status(200).json({ message: 'Password changed successfully' });
        }
        else {
            return res.status(404).json({ message: 'User not found' });
        }
    }else {
        return res.status(400).json({ message: 'No valid data received' });
    }

    console.log('Data: ',rData);
    res.status(200).json({ message: 'Data received successfully', data: rData });
});

app.post('/user/signin',(req,res) => {
    rData = req.body;

    if(rData.email && rData.password){
        const user = users.find(u => u.email == rData.email);
        if(user){
            if(user.password === rData.password){
                console.log(`Correct passwords for user with email: ${rData.email}`);
            }
            else{
                console.log(`Passwords don't match for user with email: ${rData.email}`);
                return res.status(401).json({ message: 'Login failed' });
            }
        }else{
            return res.status(404).json({ message: 'User not found' });
        }
        }else{
            return res.status(400).json({ message: 'No valid data received' });
        }

        console.log('Data: ',rData);
        res.status(200).json({ message: 'Data received successfully', data: rData });
});

app.post('/user/signup',(req,res) => {
    rData = req.body;
    if(rData){
        //Implement required sign up logic here (adding new user to external db)

        console.log('Data: ',rData);
        res.status(200).json({ message: 'Data received successfully', data: rData });
    }else{
        return res.status(400).json({ message: 'No valid data received' });
    }
});


app.get('/api/courses',(req,res) => {
    res.json(courses)
})
app.get('/api/users',(req,res) => {
    res.json(users)
})

app.get('/',(req,res) => {
    res.send('CircuitAcademy server');
  })

app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
   })
   
