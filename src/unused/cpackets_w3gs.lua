-- Packets from client to server
CPacketDescription = {
--[[doc
    Message ID:      0x7D

    Message Name:    BNLS_WARDEN

    Message Status:  MORE RESEARCH NEEDED

    Direction:       Client -> Server (Sent)

    Used By:         Starcraft Broodwar, Warcraft III: The Frozen Throne, Starcraft,
                     Warcraft III

    Format:          (BYTE) Command
                     (DWORD) Cookie

                     Command 0x00 (Warden Seed):
                     (DWORD) Client
                     (WORD) Length of Seed
                     (VOID) Seed
                     (STRING) Username (blank)
                     (WORD) Length of password
                     (VOID) Password

                     Command 0x01 (warden packet):
                     (WORD) Length Of Warden Packet
                     (VOID) Warden Packet Data

                     Command 0x02 (warden 0x05):
                     (DWORD) Client
                     (WORD) Length Of Seed
                     (VOID) Seed
                     (DWORD) Unused
                     (BYTE) [16] Module MD5 Name
                     (WORD) Length of Warden 0x05 packet
                     (VOID) Warden 0x05 packet

                     Command 0x03 (warden checks/ini file):
                     (DWORD) Client
                     (DWORD) Info Type (0x01)
                     (WORD) Unused (must be 0x00)
                     (VOID) Unused

    Remarks:         This packet can currently support 2 methods for SC/BW/W3ROC/W3TFT.

                     The first method (commands 0x00 and 0x01) allows you to support warden
                     over battle.net with out any need for installing warden related code
                     and algorithm. It does however, require you to stay connected to the
                     server, or at least, connect each time a new request comes in from
                     Battle.net.

                     The second method (commands 0x02 and 0x03) allows you to support the
                     more basic side of warden, why leaving all the more complex things to
                     the BNLS server. One side to this method, allows you to support
                     warden, without having to worry about downloading, loading and
                     executing warden modules, from Battle.net.

                     A basic description of the packet values above:
                     The command tells the BNLS server how to parse your request.

                     0x00 is for initializeing a new Battle.net connection, to
                     allocate a packet handler for you, on the server.

                     0x01 is for having your warden requests handled, via the
                     preallocated packet handler, done in command 0x00.

                     0x02 is for getting the correct data in response to warden 0x05
                     and a new set of RC4 keys, as well as any other future module
                     requiring packets.

                     0x03 is for getting a list of offsets and their contents, to be
                     used in your warden 0x02 handler.
                     The cookie is sent back to the client, to identify one request from
                     another. With command 0x01, the cookie must remain the same as the one
                     you initialized for a given Battle.net connection, with command 0x00.

                     It is important to use different cookies for differnt bots when
                     dealing with commands 0x00 and 0x01, so you do not have a RC4
                     encryption key corrupted and therefor having to reconnect to
                     Battle.net. For more info on commands 0x00 and 0x01 cookies, see the
                     "First Method" description below.

                     The client value identifies what client you connected to Battle.net
                     with. It can be the DWORD you use over Battle.net (such as PXES) or
                     one of the below:

                     0x01 = Starcraft

                     0x02 = Broodwar

                     0x03 = Warcraft 2

                     0x04 = Diablo 2

                     0x05 = Diablo 2 LOD

                     0x06 = Starcraft Japan

                     0x07 = Warcraft 3

                     0x08 = Warcraft 3 TFT

                     0x09 = Diablo

                     0x0A = Diablo SWare

                     0x0B = Starcraft SWare
                     The seed value is used to initialize wardens cryptography. This value
                     should be the 1st DWORD of the first CDKey hash in C>S 0x51
                     SID_AUTH_CHECK. For now, only a 4 byte seed is acceptable. If you are
                     using the older logon protocol (packets 0x06, 0x07, etc), this seed
                     value should be zero.

                     The Module MD5 Name is obtained from the warden 0x01 packet, starting
                     at the 2nd byte.

                     The username and password are for possible future updates, they can be
                     ignored for now - just leave the username blank and the length of
                     password to zero.

                     For the result value in the response, see the "Result values and
                     meanings" description below.

                     First Method (commands 0x00 and 0x01)
                     This connection style allows you to support warden over Battle.net
                     without any need for installing warden related code and algorithms
                     into your program. It does however, require you stay connected to the
                     server, or at least, connect each time a new request comes in from
                     Battle.net. This is basically a fully managed remote warden handler.
                     The Cookie value is used to allocate (command 0x00) and access
                     (command 0x01) a warden connection/handler. Once you initialize a
                     cookie (command 0x00), it can then be sent back to BNLS with a
                     Battle.net warden packet (command 0x01) to have the request handled,
                     and a response sent back to you to be sent on to Battle.net. You can
                     manage multiple Battle.net connections/wardens via one or more BNLS
                     sockets.

                     Command 0x00:
                     When logging onto Battle.net and building your C>S 0x51 SID_AUTH_CHECK
                     packet, you need to obtain the first DWORD of the first cdkey hash
                     which will be the seed value used in command 0x00. You then send this
                     seed value to BNLS, via command 0x00, to activate, or reset the given
                     cookie. This cookie value must be different from any other bots using
                     the same BNLS server from your network, that way you do not have
                     clashes. The BNLS server will respond telling you if the cookie was
                     successfully initialized or not. The data in the response should only
                     ever be present if the response contains an error code.

                     Command 0x01:
                     Once you have successfully initialized a cookie for a Battle.net
                     connection, you are ready to forward all Battle.net warden traffic to
                     BNLS. If the result comes back with an error code, the "Warden Packet
                     Data" may contain infomation about the given error code. If the result
                     comes back successful, then the "Warden Packet Data" will contain the
                     BNCS 0x5E SID_WARDEN payload to be sent to Battle.net. You should only
                     send the response data to Battle.net if the request was successful,
                     the length of the data is one or more and it is a 0x01 command
                     response. Please note that after initializing a cookie with command
                     0x00, that space will remain allocated on the server, for up to three
                     minutes. This allows you to reconnect, and still be able to resume
                     where you left off, without having to reconnect to Battle.net. You
                     should only send the PAYLOAD of the S>C BNCS 0x5E SID_WARDEM packet,
                     and NOT the full BNCS packet.

                     Second Method (commands 0x02 and 0x03)
                     This allows you to manage your own warden handler, and avoid the need
                     to download and manage warden modules from Battle.net.

                     Command 0x02:
                     This is for managing packets that only the downloaded warden modules
                     can do. Warden sends you an 0x05 packet that iss used to verify that
                     you are truly running the correct warden module. You can send the
                     whole decrypted 0x05 packet (including the packet ID) and get the 0x04
                     response and new set of RC4 keys. Since the algorithm warden uses to
                     generate the 0x04 response data is differnt in each downloaded module,
                     this usage requires you also send your orginal seed and the module
                     name. It is possible, in the future, that more modules requiring
                     packets, such as 0x05, may come into play. Because of that, the data
                     in the response to command 0x02 maybe vary. This is the current
                     supported format for the "data" in command 0x02 responses:

                     (DWORD) Response Type
                     Type 0x01:

                     (BYTE) [258] New RC4 In Key

                     (BYTE) [258] New RC4 Out Key

                     (DWORD) Length Of warden Response

                     (VOID) Warden responce packet Data
                     The warden response packet data will be the whole raw 0x04 packet. You
                     then encrypt the response packet data with your existing RC4 Out key,
                     then replace your existing RC4 keys with the new ones. It is possible
                     that the BNLS server may respond with the result code 0x03 (warden
                     module not loaded). There is a short delay between Battle.net
                     switching to a new warden module and the BNLS server downloading it
                     from Battle.net, so try again in 10 or more seconds.

                     Command 0x03:
                     This allows you to download a file and/or information about the checks
                     warden is making. This infomation can be used by your warden 0x02
                     parser to identify the check type and its result. Currently the only
                     info type 0x01 is supported (downloading of a .ini file). The "data"
                     in the response to command 0x03 has the following format:

                     (DWORD) Into type
                     For type 0x01:

                     (DWORD) [2] File time

                     (VOID) ini File data

                     It may in the future support more info types, depending in what
                     direction warden goes.

    Related:         [0x51] SID_AUTH_CHECK (C->S), [0x7D] BNLS_WARDEN (S->C),
                     [0x5E] SID_WARDEN (S->C)

]]
[BNLS_WARDEN] = { -- 0x7D
	uint8("Command"),
	uint32("Cookie"),
	uint32("Client"),
	uint16("Length of Seed"),
	bytes("Seed"),
	stringz("Username"),
	uint16("Length of password"),
	bytes("Password"),
	uint16("Length Of Warden Packet"),
	bytes("Warden Packet Data"),
	uint32("Client"),
	uint16("Length Of Seed"),
	bytes("Seed"),
	uint32("Unused"),
	uint8("[16] Module MD5 Name"),
	uint16("Length of Warden 0x05 packet"),
	bytes("Warden 0x05 packet"),
	uint32("Client"),
	uint32("Info Type"),
	uint16("Unused"),
	bytes("Unused"),
},
--[[doc
    Message ID:    0x1E

    Message Name:  W3GS_REQJOIN

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Host Counter (Game ID)
                   (DWORD) Entry Key (used in LAN)
                   (BYTE) Unknown
                   (WORD) Listen Port
                   (DWORD) Peer Key
                   (STRING) Player name
                   (DWORD) Unknown
                   (WORD) Internal Port
                   (DWORD) Internal IP

    Remarks:       A client sends this to the host to enter the game lobby.

                   The internal IP uses the Windows sockaddr_in structure.

    Related:       [0x05] W3GS_REJECTJOIN (S->C), [0x04] W3GS_SLOTINFOJOIN (S->C),
                   [0x06] W3GS_PLAYERINFO (S->C), [0x3D] W3GS_MAPCHECK (S->C)

]]
[W3GS_REQJOIN] = { -- 0x1E
	uint32("Host Counter"),
	uint32("Entry Key"),
	uint8("Unknown"),
	uint16("Listen Port"),
	uint32("Peer Key"),
	stringz("Player name"),
	uint32("Unknown"),
	uint16("Internal Port"),
	uint32("Internal IP"),
},
--[[doc
    Message ID:    0x21

    Message Name:  W3GS_LEAVEREQ

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Reason

    Remarks:       A client requests to leave.

                   Reasons:
                   0x01 PLAYERLEAVE_DISCONNECT

                   0x07 PLAYERLEAVE_LOST

                   0x08 PLAYERLEAVE_LOSTBUILDINGS

                   0x09 PLAYERLEAVE_WON

                   0x0A PLAYERLEAVE_DRAW

                   0x0B PLAYERLEAVE_OBSERVER

                   0x0D PLAYERLEAVE_LOBBY

    Related:       [0x1E] W3GS_REQJOIN (C->S), [0x1B] W3GS_LEAVERES (S->C)

]]
[W3GS_LEAVEREQ] = { -- 0x21
	uint32("Reason"),
},
--[[doc
    Message ID:    0x23

    Message Name:  W3GS_GAMELOADED_SELF

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        [blank]

    Remarks:       The client sends this to the host when they have finished loading the
                   map.

    Related:       [0x08] W3GS_PLAYERLOADED (S->C), [0x0B] W3GS_COUNTDOWN_END (S->C)

]]
[W3GS_GAMELOADED_SELF] = { -- 0x23
},
--[[doc
    Message ID:    0x26

    Message Name:  W3GS_OUTGOING_ACTION

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) CRC-32 encryption
                   (VOID) Action data

    Remarks:       A client sends this to the game host to execute an action in-game.

    Related:       [0x0C] W3GS_INCOMING_ACTION (S->C)

]]
[W3GS_OUTGOING_ACTION] = { -- 0x26
	uint32("CRC-32 encryption"),
	bytes("Action data"),
},
--[[doc
    Message ID:    0x27

    Message Name:  W3GS_OUTGOING_KEEPALIVE

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Unknown

    Remarks:       This is sent to the host from each client.

                   The unknown value may be a checksum and is also used in replays.

]]
[W3GS_OUTGOING_KEEPALIVE] = { -- 0x27
	uint32("Unknown"),
},
--[[doc
    Message ID:    0x28

    Message Name:  W3GS_CHAT_TO_HOST

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (BYTE) Total

                   For each total:
                   (BYTE) To player number
                   (BYTE) From player number
                   (BYTE) Flags
                   For Flag 0x10:

                   (STRING) Message

                   For Flag 0x11:

                   (BYTE) Team

                   For Flag 0x12:

                   (BYTE) Color

                   For Flag 0x13:

                   (BYTE) Race

                   For Flag 0x14:

                   (BYTE) Handicap

                   For Flag 0x20:

                   (DWORD) Extra Flags

                   (STRING) Message

    Remarks:       This is sent from the client to the host to send a message to the
                   other clients.

    Related:       [0x0F] W3GS_CHAT_FROM_HOST (S->C)

]]
[W3GS_CHAT_TO_HOST] = { -- 0x28
	uint8("Total"),
	uint8("To player number"),
	uint8("From player number"),
	uint8("Flags"),
	stringz("Message"),
	uint8("Team"),
	uint8("Color"),
	uint8("Race"),
	uint8("Handicap"),
	uint32("Extra Flags"),
	stringz("Message"),
},
--[[doc
    Message ID:    0x2F

    Message Name:  W3GS_SEARCHGAME

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Product
                   (DWORD) Version
                   (DWORD) Unknown (0)

    Remarks:       This is sent to the entire local area network to detect games.

                   Product is either WAR3 or W3XP.

    Related:       [0x30] W3GS_GAMEINFO (S->C)

]]
[W3GS_SEARCHGAME] = { -- 0x2F
	uint32("Product"),
	uint32("Version"),
	uint32("Unknown"),
},
--[[doc
    Message ID:    0x35

    Message Name:  W3GS_PING_FROM_OTHERS

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        [blank]

    Remarks:       Client requests an echo from another client (occurs every 10 seconds).

    Related:       [0x36] W3GS_PONG_TO_OTHERS (S->C)

]]
[W3GS_PING_FROM_OTHERS] = { -- 0x35
},
--[[doc
    Message ID:      0x37

    Message Name:    W3GS_CLIENTINFO

    Message Status:  MORE RESEARCH NEEDED

    Direction:       Client -> Server (Sent)

    Used By:         Warcraft III: The Frozen Throne, Warcraft III

    Format:          (DWORD) Player Counter
                     (DWORD) Unknown (0)
                     (BYTE) Player number
                     (BYTE)[5] Unknown

    Remarks:         A client sends this to another client to gain information about self
                     when connected.

                     The first byte in the second unknown is possibly the status of the
                     player.

                     Packet Log:
                     F7 37 12 00
                     02 00 00 00
                     00 00 00 00
                     06
                     FF 5E 00 00 00

]]
[W3GS_CLIENTINFO] = { -- 0x37
	uint32("Player Counter"),
	uint32("Unknown"),
	uint8("Player number"),
	uint8("[5] Unknown"),
},
--[[doc
    Message ID:    0x3F

    Message Name:  W3GS_STARTDOWNLOAD

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        [blank]

    Remarks:       A client sends this to the host to initiate a map download.

    Related:       [0x3D] W3GS_MAPCHECK (S->C)

]]
[W3GS_STARTDOWNLOAD] = { -- 0x3F
},
--[[doc
    Message ID:    0x42

    Message Name:  W3GS_MAPSIZE

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) Unknown
                   (BYTE) Size Flag
                   (DWORD) Map Size

    Remarks:       This is sent from the client to tell the host about the map file on
                   the client's local system.

]]
[W3GS_MAPSIZE] = { -- 0x42
	uint32("Unknown"),
	uint8("Size Flag"),
	uint32("Map Size"),
},
--[[doc
    Message ID:    0x44

    Message Name:  W3GS_MAPPARTOK

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (BYTE) To player number
                   (BYTE) From player number
                   (DWORD) Unknown
                   (DWORD) Chunk position in file

    Remarks:       The client sends this when it has successfully received a chunk of the
                   map file from the host client.

    Related:       [0x43] W3GS_MAPPART (S->C)

]]
[W3GS_MAPPARTOK] = { -- 0x44
	uint8("To player number"),
	uint8("From player number"),
	uint32("Unknown"),
	uint32("Chunk position in file"),
},
--[[doc
    Message ID:      0x45

    Message Name:    W3GS_MAPPARTNOTOK

    Message Status:  MORE RESEARCH NEEDED

    Direction:       Client -> Server (Sent)

    Used By:         Warcraft III: The Frozen Throne, Warcraft III

    Format:          [unknown]

    Remarks:         More research is required.

                     This is sent when downloading a map in reply to 0x43 W3GS_MAPPART and
                     a chunk of the map file does not match its CRC encryption.

    Related:         [0x43] W3GS_MAPPART (S->C), [0x44] W3GS_MAPPARTOK (C->S)

]]
[W3GS_MAPPARTNOTOK] = { -- 0x45
},
--[[doc
    Message ID:    0x46

    Message Name:  W3GS_PONG_TO_HOST

    Direction:     Client -> Server (Sent)

    Used By:       Warcraft III: The Frozen Throne, Warcraft III

    Format:        (DWORD) tickCount

    Remarks:       This is sent in response to 0x01 W3GS_HOSTECHOREQ.

                   The tickCount value is from GetTickCount().

                   Ping = (GetTickCount()-tickCount)/2
                   For the local area network, it can be 0.

    Related:       [0x01] W3GS_PING_FROM_HOST (S->C)

]]
[W3GS_PONG_TO_HOST] = { -- 0x46
	uint32("tickCount"),
},
--[[doc
    Message ID:      0x17

    Message Name:    SID_READMEMORY

    Message Status:  DEFUNCT

    Direction:       Client -> Server (Sent)

    Used By:         Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Warcraft II,
                     Starcraft, Starcraft Japanese, Diablo

    Format:          (DWORD) Request ID
                     (VOID) Memory

    Remarks:         Rudimentary hack detection system. Was never used probably due to
                     terrible implementation with little security.

                     Yes, it is possible for a PvPGN server to read EVERYTHING that is in
                     the process' memory, including sensitive information such as your
                     CDKey.

                     Found at:
                     battle!1901D470h (as of 1.16.1)

    Related:         [0x17] SID_READMEMORY (S->C)

]]
[SID_READMEMORY] = { -- 0x17
	uint32("Request ID"),
	bytes("Memory"),
},
--[[doc
    Message ID:      0x24

    Message Name:    SID_READCOOKIE

    Message Status:  DEFUNCT

    Direction:       Client -> Server (Sent)

    Used By:         Starcraft Shareware, Starcraft Broodwar, Diablo Shareware, Warcraft II,
                     Starcraft, Starcraft Japanese, Diablo

    Format:          (DWORD) First DWORD from S -> C
                     (DWORD) Second DWORD from S -> C
                     (STRING) Registry key name
                     (STRING) Registry key value

    Remarks:         Much like a website cookie, simply stores some arbitrary string to a
                     'cookie jar' to save preferences et al. which can be retrieved later
                     by the server.

                     Not used because it was quickly discovered that storing preferences
                     produces less problems and were faster by storing them server-side,
                     associating them with the account. It is somewhat curious that these
                     packet IDs are close to SID_PROFILE/SID_WRITEPROFILE (0x26 & 0x27).

                     Found at: battle!190216FBh and battle!1901D660h, respectively.

    Related:         [0x24] SID_READCOOKIE (S->C), [0x23] SID_WRITECOOKIE (S->C),
                     [0x26] SID_READUSERDATA (C->S)

]]
[SID_READCOOKIE] = { -- 0x24
	uint32("First DWORD from S -> C"),
	uint32("Second DWORD from S -> C"),
	stringz("Registry key name"),
	stringz("Registry key value"),
},
}
