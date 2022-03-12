import React, { useState, useEffect } from 'react';
import { ethers } from 'ethers';

interface IOpenPolygonContext {
  account: string;
  connectWallet: () => void;
}

export const OpenPolygonContext = React.createContext<IOpenPolygonContext>({
  account: '',
  connectWallet: () => {},
});

export const OpenPolygonProvider: React.FC = ({ children }) => {
  const [account, setAccount] = useState('');

  const checkIfWalletIsConnected = async () => {
    try {
      if (!(window as any).ethereum) alert('Please install Metamask!');

      const accounts = await (window as any).ethereum.request({
        method: 'eth_accounts',
      });

      if (accounts.length) {
        setAccount(accounts[0]);
      }
    } catch (error) {
      console.error(error);
    }
  };

  useEffect(() => {
    checkIfWalletIsConnected();
  }, []);

  const connectWallet = async () => {
    try {
      if (!(window as any).ethereum) alert('Please install Metamask!');

      const accounts = await (window as any).ethereum.request({
        method: 'eth_requestAccounts',
      });

      if (accounts.length) {
        setAccount(accounts[0]);
      }
    } catch (error) {
      console.error(error);
    }
  };

  return (
    <OpenPolygonContext.Provider value={{ account, connectWallet }}>
      {children}
    </OpenPolygonContext.Provider>
  );
};
