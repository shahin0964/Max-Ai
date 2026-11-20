package com.getmaya.android.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Clear
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.getmaya.android.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TerminalReelScreen(
    outputs: List<Pair<String, String>>,
    onExecuteCommand: (String) -> Unit,
    onBack: () -> Unit
) {
    var cmdInput by remember { mutableStateOf("") }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Text("Termux Bridge Reel", color = TerminalGreen, fontWeight = FontWeight.Bold)
                        Spacer(modifier = Modifier.width(8.dp))
                        Box(
                            modifier = Modifier
                                .clip(RoundedCornerShape(4.dp))
                                .background(Color(0xFF1E281E))
                                .padding(horizontal = 6.dp, vertical = 2.dp)
                        ) {
                            Text("RUN_COMMAND", color = TerminalGreen, fontSize = 10.sp)
                        }
                    }
                },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back", tint = MayaTextPrimary)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = TerminalBackground)
            )
        },
        containerColor = TerminalBackground
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(12.dp)
        ) {
            LazyColumn(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(8.dp))
                    .background(Color(0xFF0F1218))
                    .padding(12.dp)
            ) {
                if (outputs.isEmpty()) {
                    item {
                        Text(
                            text = "# Maya Termux Live Console\n# Ready to dispatch commands via com.termux.RUN_COMMAND\n# Type a command below or ask Maya by voice.",
                            color = MayaTextSecondary,
                            fontFamily = FontFamily.Monospace,
                            fontSize = 13.sp
                        )
                    }
                }
                items(outputs) { (cmd, out) ->
                    Column(modifier = Modifier.padding(vertical = 6.dp)) {
                        Text(
                            text = "$ $cmd",
                            color = TerminalCyan,
                            fontFamily = FontFamily.Monospace,
                            fontWeight = FontWeight.Bold,
                            fontSize = 13.sp
                        )
                        Spacer(modifier = Modifier.height(2.dp))
                        Text(
                            text = out,
                            color = TerminalGreen,
                            fontFamily = FontFamily.Monospace,
                            fontSize = 12.sp
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(8.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                TextField(
                    value = cmdInput,
                    onValueChange = { cmdInput = it },
                    placeholder = { Text("pkg update, ls -la, python3...", color = MayaTextSecondary) },
                    modifier = Modifier
                        .weight(1f)
                        .clip(RoundedCornerShape(8.dp)),
                    colors = TextFieldDefaults.colors(
                        focusedContainerColor = MayaSurfaceElevated,
                        unfocusedContainerColor = MayaSurfaceElevated,
                        focusedTextColor = Color.White,
                        unfocusedTextColor = Color.White
                    ),
                    singleLine = true
                )
                Spacer(modifier = Modifier.width(8.dp))
                IconButton(
                    onClick = {
                        if (cmdInput.isNotBlank()) {
                            val c = cmdInput
                            cmdInput = ""
                            onExecuteCommand(c)
                        }
                    },
                    modifier = Modifier
                        .clip(RoundedCornerShape(8.dp))
                        .background(TerminalGreen)
                ) {
                    Icon(Icons.Default.PlayArrow, contentDescription = "Run", tint = Color.Black)
                }
            }
        }
    }
}
