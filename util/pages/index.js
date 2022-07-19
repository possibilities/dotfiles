import React from 'react'
import * as colors from 'colors'

const Page = () => {
  const [date, setDate] = React.useState(null)
  React.useEffect(() => {
    const timeout = setTimeout(() => setDate(new Date()), 1000)
    return () => {
      clearTimeout(timeout)
    }
  })
  return (
    <>
      <style jsx global>
        {`
          body {
            background: ${colors.nord1};
            margin: 0;
          }
        `}
      </style>
      <style>
        {`
          .container {
            display: flex;
            height: 100vh;
            flex-direction: column;
            align-items: center;
            justify-content: center;
          }
        `}
      </style>
      {date && (
        <div className='container'>
          <style>
            {`
            .time {
              color: ${colors.nord4};
              font-size: 15vw;
              font-family: Fira Code;
            }
            .date {
              color: ${colors.nord4};
              font-size: 9vw;
              font-family: Fira Code;
              text-align: center;
            }
          `}
          </style>
          <div className='time'>{date.toLocaleTimeString()}</div>
          <div className='date'>
            {date.toLocaleDateString('en-us', {
              year: 'numeric',
              month: 'long',
              day: 'numeric',
            })}
          </div>
        </div>
      )}
    </>
  )
}

export default Page
