import Head from 'next/head'
import Image from 'next/image'
import { useState, useEffect } from 'react'
import { contractAddress, contractABI } from '../contractDetail'
import { ethers } from 'ethers'

export default function Home() {
	//const [alreadyMinted, setAlreadyMinted] = useState() forgot tomake no of minted public var so skip for now
	const [currentAccount, setCurrentAccount] = useState()
	const [loading, setLoading] = useState(false)
	const [notify, setNotify] = useState(false)
	const [alreadyMinted, setAlreadyMinted] = useState()
	const checkIfWalletIsConnected = async () => {
		/*
		 * First make sure we have access to window.ethereum
		 */
		const { ethereum } = window

		if (!ethereum) {
			console.log('Make sure you have metamask!')
			return
		} else {
			console.log('We have the ethereum object', ethereum)
		}

		const accounts = await ethereum.request({ method: 'eth_accounts' }) // get the accounts from metamask

		if (accounts.length !== 0) {
			const account = accounts[0]
			console.log('Found an authorized account:', account)
			setCurrentAccount(account)
		} else {
			console.log('No authorized account found')
		}
	}
	useEffect(() => {
		checkIfWalletIsConnected()
	}, [])

	const connectWallet = async () => {
		try {
			const { ethereum } = window
			if (!ethereum) {
				alert("You don't MetaMask!")
				return
			}
			const accounts = await ethereum.request({
				method: 'eth_requestAccounts',
			})
			console.log('Connected', accounts[0])
			setCurrentAccount(accounts[0])
			// show minted orbs
			const provider = new ethers.providers.Web3Provider(ethereum)
			const signer = provider.getSigner()
			const connectedContract = new ethers.Contract(
				contractAddress,
				contractABI,
				signer
			)
			//checking the chainID
			let chainId = await ethereum.request({ method: 'eth_chainId' })
			console.log('Connected to chain ' + chainId)

			// String, hex code of the chainId of the Rinkebey test network
			const rinkebyChainId = '0x4'
			if (chainId !== rinkebyChainId) {
				alert('You are not connected to the Rinkeby Test Network!')
			}
			//
			await connectedContract
				.noOfNormal()
				.then((res) => setAlreadyMinted(parseInt(res._hex)))
		} catch (err) {
			console.log(err)
		}
	}

	// Minting function
	const askContractToMintNft = async () => {
		const CONTRACT_ADDRESS = contractAddress

		try {
			const { ethereum } = window

			if (ethereum) {
				const provider = new ethers.providers.Web3Provider(ethereum)
				const signer = provider.getSigner()
				const connectedContract = new ethers.Contract(
					CONTRACT_ADDRESS,
					contractABI,
					signer
				)

				console.log('Going to pop wallet now to pay cost + gas...')
				setLoading(true)
				const costOrb = await connectedContract.normalCost()
				const options = { value: costOrb._hex }
				let nftTxn = await connectedContract.makeAnEpicOrb(0, options)

				console.log('Mining...please wait.')
				await nftTxn.wait()
				if (nftTxn) {
					setLoading(false)
					//update ui
					await connectedContract
						.noOfNormal()
						.then((res) => setAlreadyMinted(parseInt(res._hex)))
					setNotify(true)
				}

				console.log(
					`Mined, see transaction: https://rinkeby.etherscan.io/tx/${nftTxn.hash}`
				)
			} else {
				console.log("Ethereum object doesn't exist!")
			}
		} catch (error) {
			console.log(error)
			setLoading(false)
		}
	}

	const transferBal = async () => {
		try {
			const { ethereum } = window

			if (ethereum) {
				const provider = new ethers.providers.Web3Provider(ethereum)
				const signer = provider.getSigner()
				const connectedContract = new ethers.Contract(
					contractAddress,
					contractABI,
					signer
				)
				setLoading(true)
				let nftTxn = await connectedContract.payOwner()

				console.log('paying owner wait')
				await nftTxn.wait()
				if (nftTxn) {
					setLoading(false)
				}

				console.log(
					`Mined, see transaction: https://rinkeby.etherscan.io/tx/${nftTxn.hash}`
				)
			} else {
				console.log("Ethereum object doesn't exist!")
			}
		} catch (error) {
			console.log(error)
			setLoading(false)
		}
	}

	const renderNotConnectedContainer = () => (
		<button
			className='button text-white bg-black hover:bg-gray-800 border-2 border-white'
			onClick={connectWallet}
		>
			Connect to Wallet
		</button>
	)
	const renderConnectedContainer = () =>
		loading ? (
			<div className='h-10 w-10 animate-spin border-t-2 rounded-full mt-4'></div>
		) : (
			<button
				className='button text-white bg-black hover:bg-gray-800 border-2 border-white'
				onClick={askContractToMintNft}
			>
				Mint an Orb...
			</button>
		)
	return (
		<>
			<Head>
				<title>Get a unique orb</title>
			</Head>
			<div className='App'>
				<div className='container bg-slate-900 h-[100vh] w-[100vw] relative overflow-hidden'>
					<div className='flex flex-col items-center justify-center'>
						<p className='text-4xl font-semibold bg-gradient-to-br from-[#36d41a] to-[#00eeff] text-transparent bg-clip-text p-2 mt-16'>
							My ORBs Collection
						</p>
						<p className='sub-text bg-gradient-to-bl from-[#711ad4] to-[#00eeff] text-transparent bg-clip-text p-2'>
							Each unique. Get your Lucky ORB today.
						</p>
						<Image
							src='https://storage.opensea.io/files/ba27819c24b4cf9719aa39e2eae37b7a.svg'
							height='200'
							width='200'
						/>
						{alreadyMinted ? (
							<div className='m-2 text-white text-2xl font-thin'>
								{alreadyMinted} / 143 are already Minted
							</div>
						) : (
							<></>
						)}
						{/* Add your render method here */}
						{!currentAccount
							? renderNotConnectedContainer()
							: renderConnectedContainer()}
						<div className='flex gap-2'>
							<a
								href='https://twitter.com/ShobhitSundriy1'
								target='_blank'
								className='mt-2 text-transparent ml-6 bg-gradient-to-r from-blue-300 to-blue-600 bg-clip-text font-semibold'
							>
								Follow me on twitter
							</a>
							<p className='text-yellow-50 p-1 pt-2'>|</p>
							<a
								href='https://testnets.opensea.io/collection/not-dragon-balls'
								target='_blank'
								className='mt-2 text-blue-600 bg-gradient-to-l from-blue-200 to-blue-600 bg-clip-text font-semibold'
							>
								View collection on opensea
							</a>
						</div>
					</div>
					<div
						className={`${
							notify ? 'bottom-4' : '-bottom-20'
						} bg-green-500 absolute transition-all delay-150 ml-4 p-2 rounded-xl`}
					>
						<a
							className='text-zinc-900'
							href={`https://testnets.opensea.io/assets/${contractAddress}/${
								alreadyMinted - 1
							}`}
							target='_blank'
							onClick={() => setNotify(false)}
						>
							Click here to see your orb on opensea
						</a>
					</div>
				</div>
			</div>
		</>
	)
}
