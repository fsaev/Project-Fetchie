#include "uart_emu.h"

UartEmu::UartEmu(int baud_rate) : m_baud_rate(baud_rate), m_state(uart_state::IDLE) {
    // Initialize the FIFOs
    m_tx_fifo = std::queue<bool>();
    m_rx_fifo = std::queue<bool>();
}

bool UartEmu::send(uint8_t* data, size_t size) {
    for (size_t i = 0; i < size; i++) {
        // Add the start bit
        m_tx_fifo.push(false);

        // Add the data bits
        for (size_t j = 0; j < 8; j++) {
            m_tx_fifo.push((data[i] >> j) & 0x01);
        }

        // Add the stop bit
        m_tx_fifo.push(true);
    }

    return true;
}

bool UartEmu::send(std::string data) {
    return send((uint8_t*)data.c_str(), data.size());
}

void UartEmu::tick(int tickcount, Vtop* top) {
    // Transmit the next bit
    // bool tx_bit = m_tx_fifo.front();
    // m_tx_fifo.pop();

    // // Print the transmitted bit
    // std::cout << (tx_bit ? "1" : "0") << std::flush;
}