-- http://www.nandland.com
-- https://youtu.be/Jy5jRhDqNss

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART_TX is

	generic (

		g_CLKS_PER_BIT : integer := 5208  -- 50Mhz/9600bps
	);

	port(

		CLK           : in std_logic;
		TX_DATA_VALID : in std_logic;  -- used to start transmission
		TX_DATA       : in std_logic_vector( 7 downto 0 );  -- buffer
		TX_LINE       : out std_logic;
		TX_ACTIVE     : out std_logic;
		TX_DONE       : out std_logic
	);

end entity;


architecture arch of UART_TX is

	type STATEMACHINE is ( 

		s_idle,      -- waiting
		s_startBit,  -- sending start bit
		s_dataBits,  -- sending data bits
		s_stopBit    -- sending stop bit
	);

	signal state : STATEMACHINE := s_idle;

	signal clkCount  : integer range 0 to g_CLKS_PER_BIT - 1 := 0;
	signal dataIndex : integer range 0 to 7 := 0;
	signal data      : std_logic_vector( 7 downto 0 ) := ( others => '0' );
	signal done      : std_logic := '0';

begin

	TX_DONE <= done;

	process( CLK )

	begin

		if rising_edge( CLK ) then

			case state is

				-- Idle state

				when s_idle =>

					TX_LINE <= '1';  -- drive line high to indicate idle

					TX_ACTIVE <= '0';
					done <= '0';
					clkCount <= 0;
					dataIndex <= 0;

					if TX_DATA_VALID = '1' then

						data <= TX_DATA; -- save data to send in case updates in the meanwhile

						state <= s_startBit;

					else
						
						state <= s_idle;

					end if;

				-- Start bit state

				when s_startBit =>

					TX_ACTIVE <= '1';

					TX_LINE <= '0';  -- drive line low to indicate start bit

					-- Wait for start bit to finish

					if clkCount < g_CLKS_PER_BIT - 1 then

						clkCount <= clkCount + 1;

						state <= s_startBit;

					else
						
						clkCount <= 0;

						state <= s_dataBits;

					end if;

				-- Data bits state

				when s_dataBits =>

					TX_LINE <= data( dataIndex );  -- send bit

					-- Wait for bit to finish

					if clkCount < g_CLKS_PER_BIT - 1 then

						clkCount <= clkCount + 1;

						state <= s_dataBits;

					else
						
						clkCount <= 0;

						-- Check if we have sent out all the data

						if dataIndex < 7 then

							dataIndex <= dataIndex + 1;

							state <= s_dataBits;

						-- Sent all data

						else

							dataIndex <= 0;

							state <= s_stopBit;

						end if;

					end if;

				-- Stop bit state

				when s_stopBit =>

					TX_LINE <= '1';  -- drive line high	to indicate stop bit

					-- Wait for bit to finish 	

					if clkCount < g_CLKS_PER_BIT - 1 then

						clkCount <= clkCount + 1;

						state <= s_stopBit;

					else
						
						clkCount <= 0;

						TX_ACTIVE <= '0';
						done <= '1';

						state <= s_idle;

					end if;

				-- Shouldn't get here

				when others =>

					state <= s_idle;

			end case;

		end if;

	end process;

end architecture;