import { useEffect, useState, useCallback } from "react";
import Web3 from "web3";

import detectEthereumProvider from "@metamask/detect-provider";
import { loadContract } from "./utils/load-contract";
import useReload from "./hooks/useReload";

import "./App.css";

function App() {
  const [web3Api, setWeb3Api] = useState({
    provider: null,
    isProviderLoaded: false,
    web3: null,
    contract: null,
  });
  const [account, setAccount] = useState("");
  const [balance, setBalance] = useState("");
  const [triggerReload, reload] = useReload();
  const canConnectToContract = account && web3Api.contract;

  useEffect(() => {
    const { provider } = web3Api;

    async function setAccountListeners() {
      const evtAccountsChanged = "accountsChanged";
      const fnAccountsChanged = (accounts) => setAccount(accounts[0]);
      provider.on(evtAccountsChanged, fnAccountsChanged);

      const evtChainChanged = "chainChanged";
      const fnChainChanged = (chainId) => {
        window.location.reload();
      };

      provider.on(evtChainChanged, fnChainChanged);

      // experimental API
      provider._metamask.isUnlocked().then(async (unlocked) => {
        if (unlocked) {
          setAccount("");
        }
      });

      return () => {
        provider.on.removeListener(evtAccountsChanged, fnAccountsChanged);
        provider.on.removeListener(evtChainChanged, fnChainChanged);
      };
    }

    provider && setAccountListeners();
  }, [web3Api, web3Api.provider]);

  useEffect(() => {
    const loadProvider = async () => {
      const provider = await detectEthereumProvider();

      if (provider) {
        // provider.request({ method: "eth_requestAccounts" });
        const contract = await loadContract("Faucet", provider);
        setWeb3Api({
          web3: new Web3(provider),
          provider,
          contract,
          isProviderLoaded: true,
        });
      } else {
        setWeb3Api((api) => ({ ...api, isProviderLoaded: true }));
        console.error("Install an ethereum web wallet");
      }
    };

    loadProvider();
  }, []);

  useEffect(() => {
    const loadBalance = async () => {
      const { contract, web3 } = web3Api;
      const balance = await web3.eth.getBalance(contract.address);
      setBalance(web3.utils.fromWei(balance, "ether"));
      console.log("balance", typeof balance);
    };

    web3Api.contract && loadBalance();
  }, [web3Api, triggerReload]);

  useEffect(() => {
    const getAccount = async () => {
      const { web3 } = web3Api;
      const accounts = await web3.eth.getAccounts();
      setAccount(accounts[0]);
      console.log(typeof accounts[0]);
    };

    web3Api.web3 && getAccount();
  }, [web3Api]);

  // functions
  const addFunds = useCallback(async () => {
    const { contract, web3 } = web3Api;

    await contract.addFunds({
      from: account,
      value: web3.utils.toWei("1", "ether"),
    });

    reload();
  }, [web3Api, account, reload]);

  const withDrawFunds = useCallback(async () => {
    const { contract, web3 } = web3Api;

    const withdrawAmount = web3.utils.toWei("0.1", "ether");

    await contract.withdraw(withdrawAmount, {
      from: account,
    });

    reload();
  }, [web3Api, account, reload]);

  console.log("RENDER", account);
  return (
    <>
      <div className="faucet-wrapper">
        <div className="faucet">
          {web3Api.isProviderLoaded ? (
            <div className="is-flex is-align-items-center">
              <span>
                <strong className="mr-2">Account: </strong>
              </span>
              {account ? (
                <div>{account}</div>
              ) : !web3Api.provider ? (
                <>
                  <div className="notification is-warning is-size-6 is-rounded">
                    Wallet is not detected!{` `}
                    <a
                      target="_blank"
                      rel="noreferrer"
                      href="https://docs.metamask.io"
                    >
                      Install Metamask
                    </a>
                  </div>
                </>
              ) : (
                <button
                  className="button is-small"
                  onClick={() =>
                    web3Api.provider.request({ method: "eth_requestAccounts" })
                  }
                >
                  Connect Wallet
                </button>
              )}
            </div>
          ) : (
            <span>Looking for Web3...</span>
          )}
          <div className="balance-view is-size-2">
            Current Balance: <strong>{balance}</strong> ETH
          </div>
          {!canConnectToContract && (
            <i className="is-block">Connect to Ganache</i>
          )}
          <button
            disabled={!canConnectToContract}
            className="button is-link mr-2"
            onClick={addFunds}
          >
            Donate 1 ETH
          </button>
          <button
            disabled={!canConnectToContract}
            className="button is-primary"
            onClick={withDrawFunds}
          >
            Withdraw 0.1 ETH
          </button>
        </div>
      </div>
    </>
  );
}

export default App;

// extras
// lower level RPC call
// const rpcCallBalance = await window.ethereum.request({
//   method: "eth_getBalance",
//   params: [contract.address, "latest"],
// });
// console.log("accounts", accounts);
// console.log("balance", balance);
// console.log("rpcCallBalanceHEX", rpcCallBalance);
// console.log("rpcCallBalance", web3.utils.toBN(rpcCallBalance).toString());
