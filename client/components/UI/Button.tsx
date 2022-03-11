import React from 'react';

interface ButtonProps {
  onClick: () => void;
  children: React.ReactNode;
}

const Button: React.FC<ButtonProps> = ({ onClick, children }) => {
  return (
    <button
      className="bg-blueMain hover:bg-blue-800 text-white font-bold py-2 px-4 rounded-full mx-2"
      onClick={onClick}
    >
      {children}
    </button>
  );
};

export default Button;
