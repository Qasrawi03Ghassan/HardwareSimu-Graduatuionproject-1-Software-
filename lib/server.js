const express = require('express')
const app = express()
const port = 3000
const cors = require('cors');

app.use(cors());

app.get('/', (req, res) => {
 res.send('Welcome to CircuitAcademy main server.')
})
app.listen(port, () => {
 console.log(`Server running at http://localhost:${port}`)
})

const courses=[
    {id:1,title:'Nodal Linear Circuits 1 - 14 - Nodal Analysis, Part 1',author:'Mark Budnik',image:'https://static.vecteezy.com/system/resources/previews/004/937/500/non_2x/abstract-circuit-board-background-vector.jpg'},
    {id:2,title:'Linear Circuits 1 - 15 - Nodal Analysis, Part 2',author:'Mark Budnik',image:'https://static.vecteezy.com/system/resources/previews/026/183/030/non_2x/abstract-modern-technology-with-electronic-circuit-board-texture-background-big-data-visualization-futuristic-computer-technology-concept-design-illustration-vector.jpg'},
    {id:3,title:'Circuits and Electronics 1: Basic Circuit Analysis',author:'Massachusetts Institute of Technology',image:'https://static.vecteezy.com/system/resources/previews/004/937/500/non_2x/abstract-circuit-board-background-vector.jpg'}
]

app.get('/api/courses',(req,res) => {
    res.json(courses)
})

