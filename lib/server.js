const express = require('express')
const bodyParser = require('body-parser');
const cors = require('cors');
const nodemailer = require('nodemailer')
const {MongoClient} = require('mongodb')

const app = express()
const port = 3000

app.use(cors());
app.use(bodyParser.json());

//Use the second one for mobile 
const uri = "mongodb://127.0.0.1:27017";
//const uri = "mongodb://10.0.2.2:27017"; 

const dbName = 'circuitAcademyMainDB'; 

let client;
let db;

async function connectToDatabase() {
    if (client) {
      console.log('Already connected to MongoDB');
      return client;
    }
  
    client = new MongoClient(uri);
  
    try {
        await client.connect();
        db = client.db(dbName);
        console.log('Connected to MongoDB');
    } catch (error) {
      console.error('Error connecting to MongoDB:', error);
    }
    return db;
  }

let usersDB = [];
let coursesDB = [];
let postsDB = [];
let enrollmentDB = [];
let commentsDB = [];


async function fetchCollections() {
    if(db == null){
      db = await connectToDatabase();
    }

    if(!db){
        console.error('No database connection. Please connect first.');
        return;
    }
  
    try {
      usersDB = await db.collection('Users').find().toArray();
      coursesDB = await db.collection('Courses').find().toArray();
      postsDB = await db.collection('Posts').find().sort({ _id: -1 }).toArray();
      enrollmentDB = await db.collection('Enrollment').find().toArray();
      commentsDB = await db.collection('Comments').find().sort({ _id: -1 }).toArray();
  
    } catch (error) {
      console.error('Error:', error);
    }
  }

  async function updateUserState(user,signState){
    let result;

    if(db == null){
      db = await connectToDatabase();
    }
    const usersCollection = db.collection('Users');
    const filter = {userID:user.userID};
    const updatePass = {$set: {isSignedIn:signState}};

    try{
      result = await usersCollection.updateOne(filter,updatePass);
      console.log('Matched documents:', result.matchedCount);
      console.log('Modified documents:', result.modifiedCount);
    }catch(error){
      console.log(`Error updating user's signState in Database: ${error}`);
    }
  }

  async function updateUserPass(user,newPassword){
    let result;

    if(db == null){
      db = await connectToDatabase();
    }
    const usersCollection = db.collection('Users');
    const filter = {userID:user.userID};
    const updatePass = {$set: {password:newPassword}};

    try{
      result = await usersCollection.updateOne(filter,updatePass);
      console.log('Matched documents:', result.matchedCount);
      console.log('Modified documents:', result.modifiedCount);
    }catch(error){
      console.log(`Error updating user's password in Database: ${error}`);
    }
  }

  async function addNewUser(newUser){
    let result;

    if(db == null){
      db = await connectToDatabase();
    }
    const usersCollection = db.collection('Users');

    try{
      result = await usersCollection.insertOne(newUser);
      console.log('New user created with id: ', result.insertedId);
    }catch(error){
      console.log(`Error adding a new user in Database: ${error}`);
    }

  }

  async function addNewCourse(newCourse){
    let result;

    if(db == null){
      db = await connectToDatabase();
    }
    const coursesCollection = db.collection('Courses');

    try{
      result = await coursesCollection.insertOne(newCourse);
      console.log('New course created with id: ', result.insertedId);
      fetchCollections();
    }catch(error){
      console.log(`Error adding a new course in Database: ${error}`);
    }
  }

  async function editCourse(eCourse){
    let result;

    if(db == null){
      db = await connectToDatabase();
    }
    const coursesCollection = db.collection('Courses');

    try{
      result = await coursesCollection.updateOne({ courseID: eCourse.courseID }, 
      { $set:  {title:eCourse.title,
                image:eCourse.image,
                usersEmails:eCourse.usersEmails,
                level:eCourse.level,
                tag:eCourse.tag,
                description:eCourse.description
      }}  );
      console.log(`Course with id ${eCourse.courseID} changed successfully: ${result.modifiedCount}`);
      fetchCollections();
    }catch(error){
      console.log(`Error updating course info with id ${eCourse.courseID} from database: ${error}`);
    }
  }
  async function addNewPost(newPost){
    let result;

    if(db == null){
      db = await connectToDatabase();
    }
    const postsCollection = db.collection('Posts');

    try{
      result = await postsCollection.insertOne(newPost);
      console.log('New post created with id: ', result.insertedId);
      fetchCollections();
    }catch(error){
      console.log(`Error adding a new post in Database: ${error}`);
    }
  }
  async function deletePost(pID) {
    let result1;
    let result2;
  
    if (db == null) {
      db = await connectToDatabase();
    }
  
    const postsCollection = db.collection('Posts');
    const commentsCollection = db.collection('Comments');
    try {
      result1 = await postsCollection.deleteOne({ postID: Number(pID) });
      result2 = await commentsCollection.deleteMany({ PostID: Number(pID) });
      console.log(`Post deleted successfully: PostID: ${result1.deletedCount} , Comments IDs: ${result2.deletedCount}`);
      fetchCollections();

    } catch (error) {
      console.log(`Error deleting post with id ${pID} from database: ${error}`);
    }
  }
  

  async function addNewComment(newComm){
    let result;

    if(db == null){
      db = await connectToDatabase();
    }
    const commentsCollection = db.collection('Comments');

    try{
      result = await commentsCollection.insertOne(newComm);
      console.log('New comment created with id: ', result.insertedId);
      fetchCollections();
    }catch(error){
      console.log(`Error adding a new user in Database: ${error}`);
    }
  }

  async function deleteComment(cID){
    let result;

    if(db == null){
      db = await connectToDatabase();
    }
    const commentsCollection = db.collection('Comments');

    try{
      result = await commentsCollection.deleteOne({commentID:cID});
      console.log(`Comments deleted successfully: ${result.deletedCount}`);
      fetchCollections();
    }catch(error){
      console.log(`Error deleting comment with id ${cID} from database: ${error}`);
    }
  }

  async function addNewEnrollment(newEn){
    let result;

    if(db == null){
      db = await connectToDatabase();
    }
    const enrollmentCollection = db.collection('Enrollment');

    try{
      result = await enrollmentCollection.insertOne(newEn);
      console.log('New Enrollment created with id: ', result.insertedId);
      fetchCollections();
    }catch(error){
      console.log(`Error adding a new enrollment in Database: ${error}`);
    }
  }

  async function deleteEnrollment(enrID){
    let result;

    if(db == null){
      db = await connectToDatabase();
    }
    const enrollmentCollection = db.collection('Enrollment');

    try{
      result = await enrollmentCollection.deleteOne({id:enrID});
      console.log(`Enrollment deleted successfully: ${result.deletedCount}`);
      fetchCollections();
    }catch(error){
      console.log(`Error deleting enrollment in Database: ${error}`);
    }
  }

  


  


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

fetchCollections();

app.post('/user/forgot',async (req,res) => {
    rData = req.body;
    if(rData.email){
        const user = usersDB.find(u => u.email == rData.email);
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
        const user = usersDB.find(u => u.email == rEmail);
        if(user){
          //Function to change database value
          await updateUserPass(user,rData.newPass);

            user.password = rData.newPass;
            console.log(`Password updated successfully for user with email: ${rEmail}`);
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

app.post('/user/signin',async (req,res) => {
    rData = req.body;

    if(rData.email && rData.password){
        const user = usersDB.find(u => u.email == rData.email);
        if(user){
            if(user.password === rData.password){
                console.log(`Correct passwords for user with email: ${rData.email}`);
                console.log(user);

                //Update user signState in database to true
                await updateUserState(user,true);

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

app.post('/user/signup',async (req,res) => {
    rData = req.body;
    const user = usersDB.find(u => u.email == rData.email);

    if(rData){
        if(user){
            return res.status(401).json({ message: `User with email ${rData.email} is already registered.`});
        }
        //Implement required sign up logic here (adding new user to external db)
        await addNewUser(rData);

        usersDB.push(rData)
        console.log('User registered successfully - Data: ',rData);
        return res.status(200).json({ message: 'Data and image received successfully', data: rData });
    }else{
        return res.status(400).json({ message: 'No valid data received' });
    }
});

app.post('/user/signout',async (req,res) => {
    rData = req.body;
    const user = usersDB.find(u => u.email == rData.email);
    if(user){
        
        console.log('Data: ',rData);
        console.log(user);

        //Update user signState in database to true
        await updateUserState(user,false);

        user.isSignedIn = false;
        console.log(`Changed signin state of user ${user.email} to false successfully.`);
        //console.log(user);
        return res.status(200).json({ message: 'Data received successfully', data: rData });
    }else{
        return res.status(400).json({ message: 'No valid data received' });
    }
});


app.post('/post/create',async (req,res) => {
  rData = req.body;
  await addNewPost(rData);
  console.log(`Post with id ${rData.postID} added successfully.`);
  return res.status(200).json({ message: 'Data received successfully', data: rData });
});
app.post('/post/delete',async (req,res) => {
  rData = req.body;
  await deletePost(rData.postID);
  console.log(`Post with id ${rData.postID} deleted successfully with it's related comments.`);
  fetchCollections();
  return res.status(200).json({ message: 'Data received successfully', data: rData });
});

app.post('/comment/create',async (req,res) => {
  rData = req.body;
  await addNewComment(rData);
  console.log(`Comment with id ${rData.commentID} created successfully.`);
  return res.status(200).json({ message: 'Data received successfully', data: rData });
});
app.post('/comment/delete',async (req,res) => {
  rData = req.body;

  await deleteComment(rData.commentID);
  console.log(`Comment with id ${rData.commentID} deleted successfully.`);
  return res.status(200).json({ message: 'Data received successfully', data: rData });
  
});

app.post('/enrollment/create',async (req,res) => {
  rData = req.body;
  await addNewEnrollment(rData);
  return res.status(200).json({ message: 'Data received successfully', data: rData });
});
app.post('/enrollment/delete',async (req,res) => {
  rData = req.body;
  await deleteEnrollment(rData.id);
  return res.status(200).json({ message: 'Data received successfully', data: rData });
  
});

app.post('/course/create',async (req,res) => {
  rData = req.body;
  await addNewCourse(rData);
  return res.status(200).json({ message: 'Data received successfully', data: rData });
});

app.post('/course/edit',async (req,res) => {
  rData = req.body;
  await editCourse(rData);
  return res.status(200).json({ message: 'Data received successfully', data: rData });
});




app.get('/api/courses',(req,res) => {
    res.json(coursesDB)
})
app.get('/api/users',(req,res) => {
    res.json(usersDB)
})
app.get('/api/posts',(req,res) => {
    res.json(postsDB)
})
app.get('/api/comments',(req,res) => {
  res.json(commentsDB)
})
app.get('/api/enrollment',(req,res) => {
  res.json(enrollmentDB)
})

app.get('/',(req,res) => {
    res.send('CircuitAcademy server');
  })

app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
   })

process.on('SIGINT', async () => {
  if (client) {
    await client.close();
    console.log('MongoDB connection closed');
    process.exit(0);
  }
});
   
