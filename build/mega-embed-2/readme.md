# mega-embed-2

Web service that resolves Megacloud.blog embed-2 v3 API streams.
<br><br>


## Usage

http://localhost:4000/{embed-id}

http://localhost:4000/get/?url={megacloud-tv-url}



## Installation

Run under node.js, inside docker container or deploy to vercel. Port can be changed via env.

**Node**

To build: `npm install`

To run: `npm run start`

**Docker**

To build: `docker build -t mega-embed-2:latest .`

To run: `docker run --init --restart=always --name mega-embed-2 -d -p 4000:4000 mega-embed-2:latest`

**Vercel**

Install Vercel cli and run `vercel --prod`

or

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https%3A%2F%2Fbitbucket.org%2Fgeordilaforge%2Fmega-embed-2%2Fsrc%2Fmaster%2F&project-name=mega-embed-2)
