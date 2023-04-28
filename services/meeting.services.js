const { meeting } = require("../models/meeting.model");
const { meetingUser } = require("../models/meeting-user.model");

async function getAllMeetingUsers(meetId, callback) {
    console.log(`getAllMeetingUsers: ${meetId}`);

    meetingUser.find({ meetingId: meetId })
        .then((response) => {
            console.log(`getAllMeetingUsers: ${response.length}`);
            return callback(null, response);
        })
        .catch((error) => {
            console.log(error);
            return callback(error);
        });
}

async function startMeeting(params, callback) {
    const meetingSchema = new meeting(params);
    meetingSchema
        .save()
        .then((response) => {
            return callback(null, response);
        })
        .catch((error) => {
            return callback(error);
        });
}

async function joinMeeting(params, callback) {
    const meetingUserModel = new meetingUser(params);

    meetingUserModel
        .save()
        .then(async (response) => {
            await meeting.findOneAndUpdate({ id: params.meetingId }, { $addToSet: { "meetingUsers": meetingUserModel } });
            return callback(null, response);
        })
        .catch((error) => {
            return callback(error);
        });
}

async function isMeetingPresent(meetingId, callback) {
    console.log(meetingId);

    meeting
        .findById(meetingId)
        .populate("meetingUsers", "MeetingUser")
        .then((response) => {
            console.log(response);
            if (!response) callback("Not found Meeting with id " + meetingId, false);
            else callback(null, true);
        })
        .catch((error) => {
            return callback(error, false);
        });
}

async function checkMeetingExists(meetingId, callback) {
    console.log("meetingId", meetingId);
    meeting
        .findById(meetingId, "hostId")
        .populate("meetingUsers", "MeetingUser")
        .then((response) => {
            if (!response) callback("Not found Meeting with id " + meetingId, false);
            else callback(null, response);
        })
        .catch((error) => {
            return callback(error);
        });
}

async function getMeetingUser(params, callback) {

    const { meetingId, userId } = params;

    meetingUser.find({ meetingId, userId })
        .then((response) => {
            return callback(null, response[0]);
        })
        .catch((error) => {
            return callback(error);
        });
}

async function updateMeetingUser(params, callback) {

    const { userId } = params;

    console.log(params);
    meetingUser.updateOne({ userId: userId }, { $set: params }, { new: true })
        .then((response) => {
            return callback(null, response);
        })
        .catch((error) => {
            return callback(error);
        });
}


async function getUserbySocketId(params, callback) {

    const { meetingId, socketId } = params;

    meetingUser.find({ meetingId, socketId })
        .limit(1)
        .then((response) => {
            return callback(null, response);
        })
        .catch((error) => {
            return callback(error);
        });
}


module.exports = {
    startMeeting,
    joinMeeting,
    getAllMeetingUsers,
    isMeetingPresent,
    getMeetingUser,
    checkMeetingExists,
    getUserbySocketId,
    updateMeetingUser
};