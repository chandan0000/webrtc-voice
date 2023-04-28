export const send = (socket, response) => {
    socket.emit("response", response);
};

export const sendTo =
    (emitter, receiverId, response) => {
        emitter.to(receiverId).emit("response", response);
    };

export const broadcast = (emitter, response) => {
    emitter.broadcast.emit("response", response);
};