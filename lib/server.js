const express = require('express')
const bodyParser = require('body-parser');
const cors = require('cors');
const nodemailer = require('nodemailer')
const multer = require('multer')

const app = express()
const port = 3000

app.use(cors());
app.use(bodyParser.json());


let rData = {};

let rEmail = '';
let rCode = '';

function  generateCode() {
    return Math.floor(100000 + Math.random() * 900000).toString();
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
    {
      id: 1,
      title: "Nodal Linear Circuits 1 - 14 - Nodal Analysis, Part 1",
      author: "Mark Budnik",
      image: "Images/courseExample.webp",
      usersEmails: "test@example.com",
      level: "Beginner"
    },
    {
      id: 2,
      title: "Linear Circuits 1 - 15 - Nodal Analysis, Part 2",
      author: "Mark Budnik",
      image: "Images/courseExample.jpg",
      usersEmails: "test@example.com",
      level: "Beginner"
    },
    {
      id: 3,
      title: "Circuits and Electronics 1: Basic Circuit Analysis",
      author: "Massachusetts Institute of Technology",
      image: "Images/courseExample3.webp",
      usersEmails: "teab2978@gmail.com",
      level: "Beginner"
    },
    {
      id: 4,
      title: "Linear Circuits 1: DC Analysis",
      author: "Dr. Bonnie H. Ferri, Dr Mary Ann Weitnauer and Dr. Joyelle Harris",
      image: "Images/courseExample4.webp",
      usersEmails: "test@example.com",
      level: "Beginner"
    },
    {
        id:5,
        title: "A new course",
        author: "aa",
        image: "",
        usersEmails: "teab2978@example.com",
        level: "Beginner"
      }
  ]

const users=[
    {
      name: "Ahmad Khaled",
      username: "Ahmad99",
      email: "circuitacademyproject@gmail.com",
      password: "123456789",
      phone: "1234567890",
      imageUrl: "",
      isSignedIn: false
    },
    {
      name: "Mohammad Omar",
      username: "OmarMoh",
      email: "teab2978@gmail.com",
      password: "00000000",
      phone: "95175368420",
      imageUrl: "https://res.cloudinary.com/ds565huxe/image/upload/v1745618351/hhnbq0gdcmvhhcrykhlf.jpg",
      isSignedIn: false
    },
    {
      name: "Shams Doha",
      username: "SunnyDoha",
      email: "123doha@hotmail.com",
      password: "987654321",
      phone: "",
      imageUrl: "",
      isSignedIn: false
    },
    {
      name: "Test User",
      username: "TestUser0",
      email: "test@example.com",
      password: "123456789",
      phone: "",
      imageUrl: "https://res.cloudinary.com/ds565huxe/image/upload/v1745608184/xvw9gemxam77izccpcle.jpg",
      isSignedIn: false
    }
  ]

const posts = [
    {
        userEmail:'test@example.com',
        courseID:1,
        description:'First post in course 1!',
        imageUrl:''
    },
    {
        userEmail:'teab2978@gmail.com',
        courseID:5,
        description:'First post in the new course 5!',
        imageUrl:''
    },
]

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
                console.log(user);
                user.isSignedIn = true;
                console.log(`Changed signin state of user ${user.email} to true successfully.`);
                console.log(user);
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
    const user = users.find(u => u.email == rData.email);

    if(rData){
        //Implement required sign up logic here (adding new user to external db)
        if(user){
            return res.status(401).json({ message: `User with email ${rData.email} is already registered.`});
        }
        users.push(rData)
        console.log('User registered successfully - Data: ',rData);
        console.log(users);
        return res.status(200).json({ message: 'Data and image received successfully', data: rData });
    }else{
        return res.status(400).json({ message: 'No valid data received' });
    }
});

app.post('/user/signout',(req,res) => {
    rData = req.body;
    const user = users.find(u => u.email == rData.email);
    if(user){
        
        console.log('Data: ',rData);
        console.log(user);
        user.isSignedIn = false;
        console.log(`Changed signin state of user ${user.email} to false successfully.`);
        console.log(user);
        return res.status(200).json({ message: 'Data received successfully', data: rData });
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
app.get('/api/posts',(req,res) => {
    res.json(posts)
})

app.get('/',(req,res) => {
    res.send('CircuitAcademy server');
  })

app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
   })
   
