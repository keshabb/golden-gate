// Copyright 2017-2020 Fitbit, Inc
// SPDX-License-Identifier: Apache-2.0

package com.fitbit.goldengate.node

import com.fitbit.goldengate.bindings.stack.StackService
import com.fitbit.goldengate.peripheral.NodeDisconnectedException
import io.reactivex.Observable
import io.reactivex.disposables.Disposable
import java.util.concurrent.TimeoutException

/**
 * Interface for Golden Gate Nodes. Used to represent a connection and encapsulates the protocol
 */
abstract class Node<T: StackService>(val stackService: T) {

    /**
     * Get a reference to the connection of the [Node]. If the [Node] is not yet connected,
     * it will connect upon [subscription][Observable.subscribe]. The returned [Observable] will
     * be shared for all callers [connection] until the connection is lost or
     * [disconnected][disconnect]. A successive call after [disconnected][disconnect] will return a
     * new [Observable]. [Disposing][Disposable.dispose] the returned [Observable] will **NOT**
     * [disconnect] the connection. This method should be [Synchronized] with [disconnect] and [close]
     *
     * @return an [Observable]<[NodeConnectionStatus]>:
     *   - [NodeConnectionStatus.CONNECTED] once a connection has been established
     *   - [NodeDisconnectedException] if the [Node] disconnects unexpectedly
     *   - [TimeoutException] if connecting to the [Node] timesout
     */
    abstract fun connection(): Observable<NodeConnectionStatus>

    /**
     * Disconnects the [Node] if currently connected. All subscribers of the current connection will
     * have their disposables [disposed][Disposable.dispose]. This method should be [Synchronized]
     * with [connection] and [close]
     */
    abstract fun disconnect()

    /**
     * [Disconnects][disconnect] the [Node] and closes the [StackService] attached to the [Node]. The [Node]
     * should not be used after this is called.
     */
    @Synchronized
    internal fun close() {
        disconnect()
        stackService.close()
    }
}
