//Author: Antonio J. Cima
const { MongoClient } = require('mongodb'); //safechecking that mongodb is installed properly.

//just getting some static information for mongoDB to save us some time, like the connection info, database name, and collection name.
const uri = "mongodb://localhost:27017";
const dbName = "admin";
const colName = "unemployment";

async function FindYearRange() 
{
    const client = new MongoClient(uri); //[MongoDBConnection] I'll explain it once here, we use this to pre-grab the server we are going to connect to (1/4)

    try
    {
        await client.connect(); //[MongoDBConnection] Then we connect to the server here, using await.(2/4)
        const db = client.db(dbName);
        const collection = db.collection(colName);

        const yearRange = await collection.aggregate([ // We grab the minimum and maximum year into an array here
            {
                $group: {
                    _id: null,
                    minYear: { $min: "$Year" },
                    maxYear: { $max: "$Year" }
                }
            }
        ]).toArray(); 

        const { minYear, maxYear } = yearRange[0];
        console.log(`#1. Data spans from ${maxYear - minYear + 1} years.`); //adding 1 to add up for the descrepencay in years (ex. 2014 - 2000 = is 15 years not 14)
    } catch (error) { //[MongoDBConnection] We are using a try and catch here just because it's using connections, it's best practice to try and catch and connection errors (3/4)
        console.error("Error:", error);
    } finally { //[MongoDBConnection] We then finally close the connection, to not cause any issues with any other databases (4/4)
        await client.close();
    }
}
async function FindStates()
{
    const client = new MongoClient(uri);

    try
    {
        await client.connect();
        const db = client.db(dbName);
        const collection = db.collection(colName);

        const distinctStates = await collection.distinct("State"); //using distinct allows us to get all unique instances of the State field
        const totalStates = await collection.countDocuments({ "State": { $exists: true } }); //countDocuments simply counts all instances of State, and if it's null or not using exists: true
        console.log(`#2. Data spans from ${distinctStates.length} distinct states and ${totalStates} total states.`); 
    } catch (error) {
        console.error("Error:", error);
    } finally {
        await client.close();
    }
}

async function MysteryQuerery()
{
    const client = new MongoClient(uri);

    try
    {
        await client.connect();
        const db = client.db(dbName);
        const collection = db.collection(colName);

        const query = await collection.countDocuments({ Rate: { $lt: 1.0 } }); //I've re-arranged the query a little for it to work in javaScript, using it this way preserves the query I believe
        console.log(`#3. The mystery query is: ${query}`);
    }
    catch (error) {
        console.error("Error:", error);
    }
    finally
    {
        await client.close();
    }
}

async function FindCountiesAbove10Percent() {
    const client = new MongoClient(uri);

    try
    {
        await client.connect();
        const db = client.db(dbName);
        const collection = db.collection(colName);

        const countiesAbove10 = await collection.find({ Rate: { $gt: 10 } }).toArray(); // using gt in our query, it allows us to input filters, this filter, gt is implying greater than 10, which is our 10%

        console.log(`#4. There are ${countiesAbove10.length} amount of counties with unemployment higher than 10%`);
    }
    catch (error)
    {
        console.error("Error:", error);
    }
    finally
    {
        await client.close();
    }
}

async function CalculateAverageUnemploymentRate()
{
    const client = new MongoClient(uri);

    try
    {
        await client.connect();
        const db = client.db(dbName);
        const collection = db.collection(colName);

        const result = await collection.aggregate([ //I could get a little lazy here by just getting the average rate of all unemployment rates seeing as I was just getting the average from all states.
            {
                $group:
                {
                    _id: null, 
                    avgRate: { $avg: "$Rate" }  //the avg keyword here is how we're getting the average.
                }
            }
        ]).toArray();

        console.log(`#5. The average unemployment rate across all states is: ${result[0].avgRate}%`);


    } catch (error) {
        console.error("Error:", error);
    } finally {
        await client.close();
    }
}

async function FindCountiesBetween5And8Percent() {
    const client = new MongoClient(uri);

    try {
        await client.connect();
        const db = client.db(dbName);
        const collection = db.collection(colName);

        const countiesBetween5And8 = await collection.find({ //We do this query similar to query #4 but we use gt and lt to then get our data range.
            Rate: {
                $gt: 5,   
                $lt: 8    
            }
        }).toArray();
        console.log(`#6. There are ${countiesBetween5And8.length} amount of counties with unemployment higher than 5% and lower than 8%`);
    }
    catch (error) {
        console.error("Error:", error);
    }
    finally {
        await client.close();
    }
}

async function FindStateWithHighestUnemployment() {
    const client = new MongoClient(uri);

    try {
        await client.connect();
        const db = client.db(dbName);
        const collection = db.collection(colName);

        const highestUnemployment = await collection.aggregate([ //we use aggregate to group all the states together
            {
                $sort: { Rate: -1 }  //we then simply sort by rate -1, which simply allows us to sort by descending order, leaving us with the highest unemployment rate on top
            },
            {
                $limit: 1  //limit to 1 answer, being the topmost answer, and we get our result!
            }
        ]).toArray();

        console.log(`#7. The state with the highest unemployment rate is ${highestUnemployment[0].State} with the rate being: ${highestUnemployment[0].Rate}%`);
    } catch (error) {
        console.error("Error:", error);
    } finally {
        await client.close();
    }
}


async function FindCountiesAbove5Percent() {
    const client = new MongoClient(uri);

    try {
        await client.connect();
        const db = client.db(dbName);
        const collection = db.collection(colName);

        const countiesAbove10 = await collection.find({ Rate: { $gt: 5 } }).toArray(); //extremly similar to query #4, we just adjust 10 to 5 and that is it.
       
        console.log(`#8. There are ${countiesAbove10.length} amount of counties with unemployment higher than 5%`);
    }
    catch (error) {
        console.error("Error:", error);
    }
    finally {
        await client.close();
    }
}

async function FindAverageUnemploymentRateByState() {
    const client = new MongoClient(uri);

    try {
        await client.connect();
        const db = client.db(dbName);
        const collection = db.collection(colName);

        const result = await collection.aggregate([ //here we HAVE to group so we use aggregate
            {
                $group:
                {
                    _id: { state: "$State", year: "$Year" },  //we group the states and years together.
                    avgRate: { $avg: "$Rate" } //we then get the average rate using those groupings (state and year)
                }
            },
            {
                $sort: { "_id.year": 1, "_id.state": 1 } //we then sort firstly by the year than the state in earlier to older and alphabetical order.
            }
        ]).toArray();

        result.forEach(doc =>
        {
            console.log(`State: ${doc._id.state}, Year: ${doc._id.year}, Average Rate: ${doc.avgRate}%`);
        });
    } catch (error) {
        console.error("Error:", error);
    } finally {
        await client.close();
    }
}

//This is where we run my beautiful code    
FindYearRange();
FindStates();
MysteryQuerery();
FindCountiesAbove10Percent();
CalculateAverageUnemploymentRate();
FindCountiesBetween5And8Percent();
FindStateWithHighestUnemployment();
FindCountiesAbove5Percent();
FindAverageUnemploymentRateByState();
//and that is all!