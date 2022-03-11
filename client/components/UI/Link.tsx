import React from 'react';
import NextLink from 'next/link';

interface LinkProps {
  className?: string;
  href: string;
  children: React.ReactNode;
}

const Link: React.FC<LinkProps> = ({ className, href, children }) => {
  return (
    <span className={`font-bold text-white hover:text-gray-300 ${className}`}>
      <NextLink href={href}>{children}</NextLink>
    </span>
  );
};

export default Link;
