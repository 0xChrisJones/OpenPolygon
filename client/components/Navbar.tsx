import React, { useContext } from 'react';
import Image from 'next/image';
import logo from '../public/LogoDark.png';
import logoSmall from '../public/LogoSmall.svg';

import NextLink from 'next/link';
import Button from './UI/Button';
import Link from './UI/Link';

import { OpenPolygonContext } from '../context/OpenPolygonContext';

const Navbar: React.FC = () => {
  const { account, connectWallet } = React.useContext(OpenPolygonContext);

  return (
    <nav className="w-full text-sm sm:text-lg py-4 px-2 sm:px-4 bg-white shadow-xl dark:text-white dark:bg-gray-900">
      <div className="flex justify-between items-center sm:px-2">
        <NextLink href="/" passHref>
          <div className="hover:cursor-pointer">
            <span className="hidden sm:block">
              <Image
                src={logo}
                alt="OpenPolygon Image"
                width="250"
                height="38"
              />
            </span>
            <span className="flex items-center justify-center sm:hidden">
              <Image
                src={logoSmall}
                alt="OpenPolygon Image"
                width="44"
                height="44"
              />
            </span>
          </div>
        </NextLink>
        <div className="flex items-center justify-evenly">
          <Link className="px-2" href="/">
            Explore NFTs
          </Link>
          {account ? (
            <div className="bg-blueMain text-white font-bold py-2 px-4 rounded-full mx-2">{`${account.substring(
              0,
              5
            )}...${account.substring(36, 41)}`}</div>
          ) : (
            <Button onClick={connectWallet}>Connect Wallet</Button>
          )}
        </div>
      </div>
    </nav>
  );
};

export default Navbar;
