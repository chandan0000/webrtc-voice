const meetingServices = require("../services/meeting.services");
const { MeetingPayloadEnum } = require("../utils/meeting-payload.enum");

function test(abc) {
    console.log("meetingHelper: " + abc);
}

async function joinMeeting(meetingId, socket, meetingServer, payload) {
    const { userId, name } = payload.data;

    console.log(`joinMeeting: ${userId} ${meetingId}`);

    meetingServices.isMeetingPresent(meetingId, async (error, results) => {

        console.log(results);

        if (error && !results) {
            sendMessage(socket, {
                type: MeetingPayloadEnum.NOT_FOUND,
            });
        }
        if (results) {

            addUser(socket, { meetingId, userId, name }).then(
                (result) => {
                    console.log(`AddUser: ${result}`);
                    if (result) {

                        sendMessage(socket, {
                            type: MeetingPayloadEnum.JOINED_MEETING,
                            data: {
                                userId,
                            },
                        });

                        //notifiy other users
                        broadcastUsers(meetingId, socket, meetingServer, {
                            type: MeetingPayloadEnum.USER_JOINED,
                            data: {
                                userId,
                                name,
                                ...payload.data,
                            },
                        });
                    }
                },
                (error) => {
                    console.log(error)
                }
            );
        }
    });
}

function forwardConnectionRequest(meetingId, socket, meetingServer, payload) {

    const { userId, otherUserId, name } = payload.data;

    var model = {
        meetingId: meetingId,
        userId: otherUserId
    };

    console.log(`forwardConnectionRequest: ${otherUserId} : ${userId}`);
    meetingServices.getMeetingUser(model, (error, results) => {

        if (results) {
            var sendPayload = JSON.stringify({
                type: MeetingPayloadEnum.CONNECTION_REQUEST,
                data: {
                    userId,
                    name,
                    ...payload.data,
                },
            });

            meetingServer.to(results.socketId).emit('message', sendPayload);
        }
    });
}

function forwardIceCandidate(meetingId, socket, meetingServer, payload) {
    const { userId, otherUserId, candidate } = payload.data;
    var model = {
        meetingId: meetingId,
        userId: otherUserId
    };

    meetingServices.getMeetingUser(model, (error, results) => {
        if (results) {

            console.log(payload.data);

            var sendPayload = JSON.stringify({
                type: MeetingPayloadEnum.ICECANDIDATE,
                data: {
                    userId,
                    candidate
                },
            });

            meetingServer.to(results.socketId).emit('message', sendPayload);
        }
    });
}

function forwardOfferSdp(meetingId, socket, meetingServer, payload) {
    const { userId, otherUserId, sdp } = payload.data;

    var model = {
        meetingId: meetingId,
        userId: otherUserId
    };

    meetingServices.getMeetingUser(model, (error, results) => {
        if (results) {
            var sendPayload = JSON.stringify({
                type: MeetingPayloadEnum.OFFER_SDP,
                data: {
                    userId,
                    sdp
                },
            });

            console.log(`forwardOfferSdp: ${otherUserId} : ${userId} : ${results.socketId}`);

            meetingServer.to(results.socketId).emit('message', sendPayload);
        }
    });
}

function forwardAnswerSdp(meetingId, socket, meetingServer, payload) {
    const { userId, otherUserId, sdp } = payload.data;

    var model = {
        meetingId: meetingId,
        userId: otherUserId
    };

    meetingServices.getMeetingUser(model, (error, results) => {
        if (results) {
            var sendPayload = JSON.stringify({
                type: MeetingPayloadEnum.ANSWER_SDP,
                data: {
                    userId,
                    sdp
                },
            });

            console.log(`forwardAnswerSdp: ${otherUserId} : ${userId} : ${results.socketId}`);

            meetingServer.to(results.socketId).emit('message', sendPayload);
        }
    });
}

function userLeft(meetingId, socket, meetingServer, payload) {
    const { userId } = payload.data;

    broadcastUsers(meetingId, socket, meetingServer, {
        type: MeetingPayloadEnum.USER_LEFT,
        data: {
            userId: userId,
        },
    });
}

function endMeeting(meetingId, socket, meetingServer, payload) {

    const { userId } = payload.data;

    broadcastUsers(meetingId, socket, meetingServer, {
        type: MeetingPayloadEnum.MEETING_ENDED,
        data: {
            userId: userId,
        },
    });

    meetingServices.getAllMeetingUsers(meetingId, (error, results) => {
        for (let i = 0; i < results.length; i++) {
            const meetingUser = results[i];
            //meetingServer.sockets.connected[meetingUser.socketId].disconnect();
        }
    });
}

function forwardEvent(meetingId, socket, meetingServer, payload) {
    const { userId } = payload.data;

    broadcastUsers(meetingId, socket, meetingServer, {
        type: payload.type,
        data: {
            userId,
            ...payload.data,
        },
    });
}

function broadcastUsers(meetingId, socket, meetingServer, payload) {
    socket.broadcast.emit("message", JSON.stringify(payload));
}

function addUser(socket, { meetingId, userId, name }) {
    let promise = new Promise(function (resolve, reject) {

        meetingServices.getMeetingUser({ meetingId, userId }, (error, results) => {
            console.log(`addUser: ${results}`);

            if (!results) {
                var model = {
                    socketId: socket.id,
                    meetingId: meetingId,
                    userId: userId,
                    joined: true,
                    name: name,
                    isAlive: true
                };

                meetingServices.joinMeeting(model, (error, results) => {
                    if (results) {
                        resolve(true);
                    }

                    if (error) {
                        reject(error);
                    }
                });
            }
            else {
                meetingServices.updateMeetingUser({
                    userId: userId,
                    socketId: socket.id,
                }, (error, results) => {
                    if (results) {
                        resolve(true);
                    }
                    if (error) {
                        reject(error);
                    }
                });
            }
        });
    });

    return promise;
}

function sendMessage(socket, payload) {
    socket.send(JSON.stringify(payload));
}

module.exports = {
    test,
    joinMeeting,
    forwardConnectionRequest,
    forwardIceCandidate,
    forwardOfferSdp,
    forwardAnswerSdp,
    userLeft,
    endMeeting,
    forwardEvent
};