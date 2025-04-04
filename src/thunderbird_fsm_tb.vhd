--+----------------------------------------------------------------------------
--| 
--| COPYRIGHT 2017 United States Air Force Academy All rights reserved.
--| 
--| United States Air Force Academy     __  _______ ___    _________ 
--| Dept of Electrical &               / / / / ___//   |  / ____/   |
--| Computer Engineering              / / / /\__ \/ /| | / /_  / /| |
--| 2354 Fairchild Drive Ste 2F6     / /_/ /___/ / ___ |/ __/ / ___ |
--| USAF Academy, CO 80840           \____//____/_/  |_/_/   /_/  |_|
--| 
--| ---------------------------------------------------------------------------
--|
--| FILENAME      : thunderbird_fsm_tb.vhd (TEST BENCH)
--| AUTHOR(S)     : Capt Phillip Warner
--| CREATED       : 03/2017
--| DESCRIPTION   : This file tests the thunderbird_fsm modules.
--|
--|
--+----------------------------------------------------------------------------
--|
--| REQUIRED FILES :
--|
--|    Libraries : ieee
--|    Packages  : std_logic_1164, numeric_std
--|    Files     : thunderbird_fsm_enumerated.vhd, thunderbird_fsm_binary.vhd, 
--|				   or thunderbird_fsm_onehot.vhd
--|
--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  
entity thunderbird_fsm_tb is
end thunderbird_fsm_tb;

architecture test_bench of thunderbird_fsm_tb is 
	
	component thunderbird_fsm is 
--	  port(
 port (
            i_clk       : in  std_logic;
            i_reset     : in  std_logic;
            i_left      : in  std_logic;
            i_right     : in  std_logic;
            o_lights_L  : out std_logic_vector(2 downto 0);
            o_lights_R  : out std_logic_vector(2 downto 0)
        );
--	  );
	end component thunderbird_fsm;

	-- test I/O signals
	 -- Test I/O Signals
    signal w_clk       : std_logic := '0';
    signal w_reset     : std_logic := '0';
    signal w_left      : std_logic := '0';
    signal w_right     : std_logic := '0';
    signal w_lights_L  : std_logic_vector(2 downto 0);
    signal w_lights_R  : std_logic_vector(2 downto 0);

    -- Constants
    constant k_clk_period : time := 10 ns;
	-- constants
	
	
begin
	-- PORT MAPS ----------------------------------------
    uut: thunderbird_fsm
        port map (
            i_clk      => w_clk,
            i_reset    => w_reset,
            i_left     => w_left,
            i_right    => w_right,
            o_lights_L => w_lights_L,
            o_lights_R => w_lights_R
        );

    -- PROCESSES ----------------------------------------

    -- Clock process
    clk_proc : process
    begin
        while true loop
            w_clk <= '0';
            wait for k_clk_period / 2;
            w_clk <= '1';
            wait for k_clk_period / 2;
        end loop;
    end process clk_proc;

    -- Test Plan Process
    test_proc : process
    begin
        -- Test 1: Reset Test
        w_reset <= '1';
        wait for k_clk_period;
        w_reset <= '0';
        wait for k_clk_period;
        assert w_lights_L = "000" and w_lights_R = "000"
            report "Test 1 Failed: FSM did not reset to OFF state" severity failure;

        -- Test 2: Left Turn Signal Sequence
        --w_left <= '1';
        ---wait for k_clk_period;
        --w_left <= '0';
        --wait for k_clk_period;
        --assert w_lights_L = "001" report "Test 2a Failed: L1 not active" severity failure;
        --wait for k_clk_period;
        --assert w_lights_L = "011" report "Test 2b Failed: L2 not active" severity failure;
        --wait for k_clk_period;
        --assert w_lights_L = "111" report "Test 2c Failed: L3 not active" severity failure;
        --wait for k_clk_period;
        --assert w_lights_L = "000" report "Test 2d Failed: L lights did not turn off" severity failure;
        -- Test 2: Left Turn Signal Sequence
        w_left <= '1';
        wait for k_clk_period;  -- Wait 1 cycle with input active
        w_left <= '0';

        -- Wait for next state (L1)
        --wait for k_clk_period;
        --assert w_lights_L = "001" report "Test 2a Failed: L1 not active" severity failure;

        wait for k_clk_period;
        assert w_lights_L = "011" report "Test 2b Failed: L2 not active" severity failure;

        wait for k_clk_period;
        assert w_lights_L = "111" report "Test 2c Failed: L3 not active" severity failure;

        wait for k_clk_period;
        assert w_lights_L = "000" report "Test 2d Failed: L lights did not turn off" severity failure;

        -- Test 3: Right Turn Signal Sequence
        w_right <= '1';
        wait for k_clk_period;
        w_right <= '0';
        wait for k_clk_period;
        assert w_lights_R = "001" report "Test 3a Failed: R1 not active" severity failure;
        wait for k_clk_period;
        assert w_lights_R = "011" report "Test 3b Failed: R2 not active" severity failure;
        wait for k_clk_period;
        assert w_lights_R = "111" report "Test 3c Failed: R3 not active" severity failure;
        wait for k_clk_period;
        assert w_lights_R = "000" report "Test 3d Failed: R lights did not turn off" severity failure;

        -- Test 4: Hazard (L + R ON)
        w_left <= '1';
        w_right <= '1';
        wait for k_clk_period;
        w_left <= '0';
        w_right <= '0';
        wait for k_clk_period;
        assert w_lights_L = "111" and w_lights_R = "111"
            report "Test 4a Failed: Hazard ON state not active" severity failure;
        wait for k_clk_period;
        assert w_lights_L = "000" and w_lights_R = "000"
            report "Test 4b Failed: Hazard OFF state not returned" severity failure;

        -- Test 5: Interrupt pattern (L1 -> R1)
        w_left <= '1';
        wait for k_clk_period;
        w_left <= '0';
        wait for k_clk_period;
        assert w_lights_L = "001" report "Test 5a Failed: L1 not active" severity failure;

        -- Now try changing to right mid-sequence (should NOT interrupt)
        w_right <= '1';
        wait for k_clk_period;
        w_right <= '0';
        wait for k_clk_period;
        assert w_lights_L = "011" report "Test 5b Failed: L2 not active" severity failure;
        wait for k_clk_period;
        assert w_lights_L = "111" report "Test 5c Failed: L3 not active" severity failure;
        wait for k_clk_period;
        assert w_lights_L = "000" report "Test 5d Failed: L sequence did not finish" severity failure;

        -- Now R1 should start after previous finishes
        wait for k_clk_period;
        assert w_lights_R = "001" report "Test 5e Failed: R1 not active after left sequence" severity failure;

        wait;

    end process test_proc;
	
end test_bench;
