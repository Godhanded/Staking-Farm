const hrc = require("hardhat")

const main = async () =>{
  const DitoFarm = await hre.ethers.getContractFactory("DitoFarm")
  const ditofarm = await DitoFarm.deploy()

  await ditofarm.deployed()
  console.log('contract address:',  ditofarm.address )
}

main()
   