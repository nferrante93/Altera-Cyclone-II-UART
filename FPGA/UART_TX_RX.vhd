-- As seen here,
--  https://youtu.be/Jy5jRhDqNss
--  https://youtu.be/fMmcSpgOtJ4

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity UART_TX_RX is

	port(

		CLK : in std_logic;  -- PIN_17

		RX_LINE : in std_logic;   -- PIN_40
		TX_LINE : out std_logic;  -- PIN_44

		BTN  : in std_logic;                       -- 1 button  -- PIN_144
		LEDS : out std_logic_vector( 2 downto 0 )  -- 3 LEDs    -- PIN_9, 7, 3
	);

end entity;

architecture arch of UART_TX_RX is

	signal dataValid_TX : std_logic := '0';
	signal data_TX      : std_logic_vector( 7 downto 0 ) := ( others => '0' );
	signal active_TX     : std_logic;
	signal done_TX       : std_logic;

	signal dataValid_RX : std_logic;
	signal data_RX      : std_logic_vector( 7 downto 0 ) := ( others => '1' ); -- LEDs are active low

	component UART_TX is

		--generic (
		--
		--	g_CLKS_PER_BIT : integer
		--);

		port(

			CLK           : in std_logic;
			TX_DATA_VALID : in std_logic;  -- used to start transmission
			TX_DATA       : in std_logic_vector( 7 downto 0 );  -- buffer
			TX_LINE       : out std_logic;
			TX_ACTIVE     : out std_logic;
			TX_DONE       : out std_logic
		);

	end component;

	component UART_RX is

		--generic (
		--
		--	g_CLKS_PER_BIT : integer;
		--	g_CLKS_PER_HALF_BIT : integer
		--);	

		port(

			CLK           : in std_logic;
			RX_LINE       : in std_logic;
			RX_DATA_VALID : out std_logic;
			RX_DATA       : out std_logic_vector( 7 downto 0 )  -- buffer
		);

	end component;

begin

	-- Instantiate UART transmitter
	UART_TX_instance : UART_TX

		--generic map (
		--
		--	5208  -- CLKS_PER_BIT 50Mhz/9600bps
		--)

		port map (

			CLK,           -- in
			dataValid_TX,  -- in
			data_TX,       -- in
			TX_LINE,       -- out
			active_TX,     -- out
			done_TX        -- out
		);

	-- Instantiate UART receiver
	UART_RX_instance : UART_RX

		--generic map (
		--
		--	5208, -- CLKS_PER_BIT
		--	2604  -- CLKS_PER_HALF_BIT
		--)

		port map (

			CLK,           -- in
			RX_LINE,       -- in
			dataValid_RX,  -- out
			data_RX        -- out
		);

	-- Do the thing
	process( CLK )

	begin

		if rising_Edge( CLK ) then

			-- Transmit if button pressed and transmitter not busy

			if BTN = '1' and active_TX = '0' then

				dataValid_TX <= '1';

				--data_TX <= "01000001";  -- ASCII 'A'
				data_TX <= data_RX;  -- Echo back received data

			else
				
				dataValid_TX <= '0';

			end if;

			---- Receive continously
				
			LEDS <= not data_RX( 2 downto 0 );  -- LEDs are active low

		end if;

	end process;

end architecture;