/*

    Socket.IOからの処理を委譲させる

*/

import Foundation


protocol DetailDelegate {
    func moveDetailView(poi : POI)
}
