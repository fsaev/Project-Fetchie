#ifndef UART_EMU_H
#define UART_EMU_H

#include <queue>
#include "Vtop.h"

class UartEmu {
    public:
        UartEmu(int baud_rate);
        void tick(int tickcount, Vtop* top);
        bool send(uint8_t* data, size_t size);
        bool send(std::string data);

    private:
        enum class uart_state {
            IDLE,
            START_BIT,
            DATA_BITS,
            STOP_BIT
        };

        int m_baud_rate;
        uart_state m_state;

        std::queue<bool> m_tx_fifo;
        std::queue<bool> m_rx_fifo;
        
};
#endif // UART_EMU_H